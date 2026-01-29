#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void print_thread_index() {
    printf("Thread ID: %d\n", threadIdx.x);
}

int main() {
    int blockSize = 8;
    int gridSize = 16;

    // Launch kernel with grid and block size
    print_thread_index<<<gridSize, blockSize>>>();

    // Wait until all GPU threads finish    
    cudaDeviceSynchronize();

    return 0;
}