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
    int h_a[N], h_b[N], h_c[N];

    // Init data in host (CPU)
    for (int i=0; i < N; i++) {
        h_a[i] = i;
        h_b[i] = i * 2; 
    }

    // Init data in device
    int *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, N * sizeof(int));
    cudaMalloc(&d_b, N * sizeof(int));
    cudaMalloc(&d_c, N * sizeof(int));

    // Copy data from host to device
    cudaMemcpy(d_a, h_a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, N * sizeof(int), cudaMemcpyHostToDevice);

    // Launch kernel
    int blockSize = 8;
    int gridSize = (N + blockSize - 1) / blockSize; // ceil
    add_vectors<<<gridSize, blockSize>>>(d_a, d_b, d_c, N);

    // Copy output from device to host
    cudaDeviceSynchronize();
    cudaMemcpy(h_c, d_c, N * sizeof(int), cudaMemcpyDeviceToHost);

    // Print result
    for (int i=0; i < N; i++) {
        printf("%d + %d = %d\n", h_a[i], h_b[i], h_c[i]);
    }

    // Free device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}