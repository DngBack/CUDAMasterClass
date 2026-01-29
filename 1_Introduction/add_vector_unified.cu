#include <stdio.h>

// Kernel for add two vector
__global__ void add_vectors(int *a, int *b, int *c, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        c[idx] = a[idx] + b[idx];
    }
}

int main() {
    const int N = 16;
    
    // ===== CÁCH 1: UNIFIED MEMORY - ĐƠN GIẢN HƠN =====
    // Khai báo con trỏ nhưng cấp phát bằng cudaMallocManaged
    // → Có thể truy cập từ cả CPU và GPU!
    int *a, *b, *c;
    cudaMallocManaged(&a, N * sizeof(int));
    cudaMallocManaged(&b, N * sizeof(int));
    cudaMallocManaged(&c, N * sizeof(int));
    
    // Init data trực tiếp (không cần h_ và d_ riêng biệt)
    for (int i = 0; i < N; i++) {
        a[i] = i;           // Viết từ CPU
        b[i] = i * 2;       // Viết từ CPU
    }
    
    // Launch kernel - KHÔNG CẦN cudaMemcpy!
    int blockSize = 8;
    int gridSize = (N + blockSize - 1) / blockSize;
    add_vectors<<<gridSize, blockSize>>>(a, b, c, N);
    
    // Đợi GPU xong
    cudaDeviceSynchronize();
    
    // Print result - đọc trực tiếp từ CPU!
    printf("=== UNIFIED MEMORY ===\n");
    for (int i = 0; i < N; i++) {
        printf("%d + %d = %d\n", a[i], b[i], c[i]);
    }
    
    // Free memory
    cudaFree(a);
    cudaFree(b);
    cudaFree(c);
    
    return 0;
}
