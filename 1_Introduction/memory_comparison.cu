#include <stdio.h>

__global__ void add_vectors(int *a, int *b, int *c, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        c[idx] = a[idx] + b[idx];
    }
}

void method_1_manual_memory() {
    printf("\n========== CÁCH 1: MANUAL MEMORY (Thủ công) ==========\n");
    printf("Ưu điểm: Kiểm soát tốt, hiệu năng cao cho dữ liệu lớn\n");
    printf("Nhược điểm: Phức tạp, dễ sai, phải copy qua lại\n\n");
    
    const int N = 8;
    
    // BƯỚC 1: Khai báo mảng trên CPU
    int h_a[8] = {0, 1, 2, 3, 4, 5, 6, 7};
    int h_b[8] = {0, 2, 4, 6, 8, 10, 12, 14};
    int h_c[8];
    
    // BƯỚC 2: Khai báo CON TRỎ trỏ đến bộ nhớ GPU
    int *d_a, *d_b, *d_c;
    
    // BƯỚC 3: Cấp phát bộ nhớ trên GPU
    cudaMalloc(&d_a, N * sizeof(int));  // d_a giờ chứa địa chỉ trên GPU
    cudaMalloc(&d_b, N * sizeof(int));
    cudaMalloc(&d_c, N * sizeof(int));
    
    // BƯỚC 4: Copy từ CPU → GPU
    cudaMemcpy(d_a, h_a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, N * sizeof(int), cudaMemcpyHostToDevice);
    
    // BƯỚC 5: Chạy kernel
    add_vectors<<<1, 8>>>(d_a, d_b, d_c, N);
    
    // BƯỚC 6: Copy kết quả GPU → CPU
    cudaDeviceSynchronize();
    cudaMemcpy(h_c, d_c, N * sizeof(int), cudaMemcpyDeviceToHost);
    
    // BƯỚC 7: In kết quả
    printf("Kết quả:\n");
    for (int i = 0; i < N; i++) {
        printf("%d + %d = %d\n", h_a[i], h_b[i], h_c[i]);
    }
    
    // BƯỚC 8: Giải phóng bộ nhớ GPU
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
}

void method_2_unified_memory() {
    printf("\n========== CÁCH 2: UNIFIED MEMORY (Tự động) ==========\n");
    printf("Ưu điểm: ĐƠN GIẢN, dễ viết, ít lỗi\n");
    printf("Nhược điểm: Có thể chậm hơn với dữ liệu lớn (do tự động chuyển)\n\n");
    
    const int N = 8;
    
    // BƯỚC 1: Cấp phát Unified Memory (dùng được cả CPU và GPU)
    int *a, *b, *c;
    cudaMallocManaged(&a, N * sizeof(int));
    cudaMallocManaged(&b, N * sizeof(int));
    cudaMallocManaged(&c, N * sizeof(int));
    
    // BƯỚC 2: Gán giá trị TRỰC TIẾP từ CPU (KHÔNG CẦN COPY!)
    for (int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i * 2;
    }
    
    // BƯỚC 3: Chạy kernel (CUDA tự động chuyển dữ liệu sang GPU)
    add_vectors<<<1, 8>>>(a, b, c, N);
    
    // BƯỚC 4: Đợi GPU xong
    cudaDeviceSynchronize();
    
    // BƯỚC 5: Đọc kết quả TRỰC TIẾP từ CPU (CUDA tự động chuyển về)
    printf("Kết quả:\n");
    for (int i = 0; i < N; i++) {
        printf("%d + %d = %d\n", a[i], b[i], c[i]);
    }
    
    // BƯỚC 6: Giải phóng bộ nhớ
    cudaFree(a);
    cudaFree(b);
    cudaFree(c);
}

void method_3_cannot_do() {
    printf("\n========== CÁCH 3: KHÔNG THỂ LÀM ĐƯỢC ==========\n");
    printf("❌ KHÔNG thể khai báo mảng tĩnh rồi dùng trên GPU!\n\n");
    
    /*
    // CODE NÀY SẼ KHÔNG CHẠY:
    int a[8] = {0, 1, 2, 3, 4, 5, 6, 7};  // Mảng trên CPU
    int b[8] = {0, 2, 4, 6, 8, 10, 12, 14};
    int c[8];
    
    // ❌ LỖI: a, b, c là địa chỉ trên CPU, GPU không truy cập được!
    add_vectors<<<1, 8>>>(a, b, c, 8);
    
    LÝ DO:
    - Mảng tĩnh int a[8] nằm trên RAM của CPU
    - GPU chỉ truy cập được VRAM (bộ nhớ GPU)
    - GPU và CPU có không gian địa chỉ hoàn toàn riêng biệt!
    */
    
    printf("Giải thích:\n");
    printf("- Mảng tĩnh int a[N] luôn nằm trên RAM (CPU)\n");
    printf("- GPU chỉ truy cập được VRAM (bộ nhớ GPU)\n");
    printf("- Phải dùng cudaMalloc hoặc cudaMallocManaged để cấp phát trên GPU\n");
}

int main() {
    printf("╔════════════════════════════════════════════════════════╗\n");
    printf("║       SO SÁNH CÁCH QUẢN LÝ BỘ NHỚ TRONG CUDA          ║\n");
    printf("╚════════════════════════════════════════════════════════╝\n");
    
    method_1_manual_memory();
    method_2_unified_memory();
    method_3_cannot_do();
    
    printf("\n");
    printf("╔════════════════════════════════════════════════════════╗\n");
    printf("║                    KẾT LUẬN                            ║\n");
    printf("╠════════════════════════════════════════════════════════╣\n");
    printf("║ • Học tập/Prototype    → Dùng UNIFIED MEMORY          ║\n");
    printf("║ • Dự án thực tế/Tối ưu → Dùng MANUAL MEMORY          ║\n");
    printf("║ • Mảng tĩnh int a[N]   → KHÔNG dùng được với GPU!    ║\n");
    printf("╚════════════════════════════════════════════════════════╝\n");
    
    return 0;
}
