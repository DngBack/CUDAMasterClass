#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void mem_trs_test(const int* data) {
    int gid = blockIdx.x * blockDim.x + threadIdx.x;
    printf("gid=%d data=%d\n", gid, data[gid]);
}

int main() {
    const int N = 128;
    size_t bytes = N * sizeof(int);

    // 1) Host alloc + init
    int* h_input = (int*)malloc(bytes);
    srand(123);
    for (int i = 0; i < N; i++) h_input[i] = rand() % 256;

    // 2) Device alloc
    int* d_input = nullptr;
    cudaMalloc((void**)&d_input, bytes);

    // 3) Copy H -> D
    cudaMemcpy(d_input, h_input, bytes, cudaMemcpyHostToDevice);

    // 4) Launch kernel (2 blocks, 64 threads/block)
    dim3 block(64);
    dim3 grid(2);
    mem_trs_test<<<grid, block>>>(d_input);
    cudaDeviceSynchronize();

    // 5) Free
    cudaFree(d_input);
    free(h_input);
    return 0;
}
