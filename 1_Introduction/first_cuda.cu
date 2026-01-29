#include <stdio.h>

// Kernel
// Show what kernal do 
__global__ void hello_cuda() {
    printf("Hello CUDA world from GPU thread!\n");
}

// CPU: Kernal / Device code
int main() {
    // Launch 10 threads, 1 block
    hello_cuda<<<1, 10>>>();

    // Wait until all GPU threads finish
    cudaDeviceSynchronize();

    return 0;
}
