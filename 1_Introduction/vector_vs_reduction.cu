#include <stdio.h>

// ============================================================
// PHÉP TOÁN 1: VECTOR ADDITION (Cộng từng phần tử)
// ============================================================
// Input:  a = [1, 2, 3, 4]
//         b = [5, 6, 7, 8]
// Output: c = [6, 8, 10, 12]  ← Mỗi phần tử riêng biệt
//
// Ứng dụng: Cộng 2 vector trong toán học, xử lý ảnh, physics
// ============================================================
__global__ void vector_addition(int *a, int *b, int *c, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        c[idx] = a[idx] + b[idx];  // Mỗi thread xử lý 1 phần tử
    }
}

// ============================================================
// PHÉP TOÁN 2: REDUCTION (Cộng tổng thành 1 số)
// ============================================================
// Input:  a = [1, 2, 3, 4]
// Output: sum = 10  ← CHỈ 1 SỐ DUY NHẤT
//
// Ứng dụng: Tính tổng, trung bình, min/max
// ============================================================
__global__ void simple_reduction(int *a, int *result, int n) {
    // CÁCH ĐƠN GIẢN (không tối ưu, chỉ để demo)
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        atomicAdd(result, a[idx]);  // Tất cả thread cộng vào 1 biến duy nhất
    }
}

void demo_vector_addition() {
    printf("\n╔════════════════════════════════════════════════════╗\n");
    printf("║  PHÉP TOÁN 1: VECTOR ADDITION (Cộng từng phần tử) ║\n");
    printf("╚════════════════════════════════════════════════════╝\n\n");
    
    const int N = 8;
    int *a, *b, *c;
    
    cudaMallocManaged(&a, N * sizeof(int));
    cudaMallocManaged(&b, N * sizeof(int));
    cudaMallocManaged(&c, N * sizeof(int));
    
    // Init data
    printf("Input:\n");
    printf("  a = [");
    for (int i = 0; i < N; i++) {
        a[i] = i + 1;
        printf("%d", a[i]);
        if (i < N-1) printf(", ");
    }
    printf("]\n");
    
    printf("  b = [");
    for (int i = 0; i < N; i++) {
        b[i] = (i + 1) * 10;
        printf("%d", b[i]);
        if (i < N-1) printf(", ");
    }
    printf("]\n\n");
    
    // Run kernel
    vector_addition<<<1, N>>>(a, b, c, N);
    cudaDeviceSynchronize();
    
    // Print result
    printf("Output:\n");
    printf("  c = [");
    for (int i = 0; i < N; i++) {
        printf("%d", c[i]);
        if (i < N-1) printf(", ");
    }
    printf("]\n");
    
    printf("\n➤ Giải thích:\n");
    printf("  • c[0] = a[0] + b[0] = 1 + 10 = 11\n");
    printf("  • c[1] = a[1] + b[1] = 2 + 20 = 22\n");
    printf("  • c[2] = a[2] + b[2] = 3 + 30 = 33\n");
    printf("  • ...\n");
    printf("  • Kết quả: MẢNG có %d phần tử\n", N);
    
    cudaFree(a);
    cudaFree(b);
    cudaFree(c);
}

void demo_reduction() {
    printf("\n╔════════════════════════════════════════════════════╗\n");
    printf("║  PHÉP TOÁN 2: REDUCTION (Cộng tổng thành 1 số)    ║\n");
    printf("╚════════════════════════════════════════════════════╝\n\n");
    
    const int N = 8;
    int *a, *sum;
    
    cudaMallocManaged(&a, N * sizeof(int));
    cudaMallocManaged(&sum, sizeof(int));
    
    // Init data
    printf("Input:\n");
    printf("  a = [");
    *sum = 0;  // Reset sum
    for (int i = 0; i < N; i++) {
        a[i] = i + 1;
        printf("%d", a[i]);
        if (i < N-1) printf(", ");
    }
    printf("]\n\n");
    
    // Run kernel
    simple_reduction<<<1, N>>>(a, sum, N);
    cudaDeviceSynchronize();
    
    // Print result
    printf("Output:\n");
    printf("  sum = %d\n", *sum);
    
    printf("\n➤ Giải thích:\n");
    printf("  • sum = a[0] + a[1] + a[2] + ... + a[7]\n");
    printf("  • sum = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8\n");
    printf("  • sum = %d\n", *sum);
    printf("  • Kết quả: CHỈ 1 SỐ DUY NHẤT\n");
    
    cudaFree(a);
    cudaFree(sum);
}

void compare_operations() {
    printf("\n╔════════════════════════════════════════════════════╗\n");
    printf("║              SO SÁNH 2 PHÉP TOÁN                   ║\n");
    printf("╚════════════════════════════════════════════════════╝\n\n");
    
    printf("┌────────────────────┬──────────────────┬────────────────────┐\n");
    printf("│                    │ VECTOR ADDITION  │    REDUCTION       │\n");
    printf("├────────────────────┼──────────────────┼────────────────────┤\n");
    printf("│ Input              │ 2 mảng (a, b)    │ 1 mảng (a)         │\n");
    printf("│ Output             │ 1 mảng (c)       │ 1 số (sum)         │\n");
    printf("│ Công thức          │ c[i] = a[i]+b[i] │ sum = Σa[i]        │\n");
    printf("│ Ví dụ input        │ a=[1,2,3,4]      │ a=[1,2,3,4]        │\n");
    printf("│                    │ b=[5,6,7,8]      │                    │\n");
    printf("│ Ví dụ output       │ c=[6,8,10,12]    │ sum=10             │\n");
    printf("│ Số kết quả         │ N phần tử        │ 1 phần tử          │\n");
    printf("│ Mỗi thread làm gì  │ Xử lý 1 cặp      │ Cộng vào tổng      │\n");
    printf("└────────────────────┴──────────────────┴────────────────────┘\n");
    
    printf("\n📌 TẠI SAO CODE CỦA BẠN DÙNG VECTOR ADDITION?\n");
    printf("   → Vì đó là bài tập cơ bản về PARALLEL COMPUTING\n");
    printf("   → Mỗi thread xử lý 1 phần tử ĐỘC LẬP\n");
    printf("   → Đây là ví dụ điển hình nhất để học CUDA!\n\n");
    
    printf("📌 KHI NÀO DÙNG REDUCTION?\n");
    printf("   → Khi cần tính TỔNG, TRUNG BÌNH, MIN, MAX của mảng\n");
    printf("   → Ví dụ: Tính tổng điểm, tìm giá trị lớn nhất, etc.\n");
}

void show_real_world_examples() {
    printf("\n╔════════════════════════════════════════════════════╗\n");
    printf("║            ỨNG DỤNG THỰC TÊ                        ║\n");
    printf("╚════════════════════════════════════════════════════╝\n\n");
    
    printf("🎨 VECTOR ADDITION (Cộng từng phần tử):\n");
    printf("   1. Xử lý ảnh: Cộng 2 ảnh lại (blending)\n");
    printf("      • Ảnh A: [255, 128, 64, ...]\n");
    printf("      • Ảnh B: [100, 50, 200, ...]\n");
    printf("      • Kết quả: [355, 178, 264, ...]  ← Mỗi pixel riêng\n\n");
    
    printf("   2. Physics simulation: Cộng lực tác động\n");
    printf("      • Lực gió: [10, 5, 3, ...]\n");
    printf("      • Lực hấp dẫn: [0, -9.8, 0, ...]\n");
    printf("      • Tổng lực: [10, -4.8, 3, ...]  ← Mỗi vật thể riêng\n\n");
    
    printf("   3. Machine Learning: Cộng gradient\n");
    printf("      • Gradient 1: [0.5, 0.2, 0.8, ...]\n");
    printf("      • Gradient 2: [0.3, 0.1, 0.4, ...]\n");
    printf("      • Tổng: [0.8, 0.3, 1.2, ...]  ← Mỗi weight riêng\n\n");
    
    printf("📊 REDUCTION (Cộng thành 1 số):\n");
    printf("   1. Tính tổng điểm của sinh viên\n");
    printf("      • Điểm: [8, 9, 7, 10, 6]\n");
    printf("      • Tổng: 40  ← CHỈ 1 SỐ\n\n");
    
    printf("   2. Đếm số pixel sáng trong ảnh\n");
    printf("      • Pixels: [255, 0, 128, 255, 200, ...]\n");
    printf("      • Số pixel > 100: 1250  ← CHỈ 1 SỐ\n\n");
    
    printf("   3. Tính trung bình nhiệt độ\n");
    printf("      • Nhiệt độ: [25, 26, 24, 27, 25]\n");
    printf("      • Trung bình: 25.4  ← CHỈ 1 SỐ\n\n");
}

int main() {
    printf("╔═══════════════════════════════════════════════════════════╗\n");
    printf("║  TẠI SAO CỘNG TỪNG PHẦN TỬ THAY VÌ CỘNG TỔNG CẢ MẢNG?   ║\n");
    printf("╚═══════════════════════════════════════════════════════════╝\n");
    
    demo_vector_addition();
    demo_reduction();
    compare_operations();
    show_real_world_examples();
    
    printf("\n╔═══════════════════════════════════════════════════════════╗\n");
    printf("║                        KẾT LUẬN                           ║\n");
    printf("╠═══════════════════════════════════════════════════════════╣\n");
    printf("║ Code của bạn dùng VECTOR ADDITION vì:                    ║\n");
    printf("║  • Đây là bài tập cơ bản nhất trong CUDA                 ║\n");
    printf("║  • Mỗi thread làm việc ĐỘC LẬP → dễ song song hóa        ║\n");
    printf("║  • Minh họa cách phân chia công việc cho GPU             ║\n");
    printf("║                                                           ║\n");
    printf("║ Nếu muốn cộng TỔNG thành 1 số → dùng REDUCTION           ║\n");
    printf("╚═══════════════════════════════════════════════════════════╝\n");
    
    return 0;
}
