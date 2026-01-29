#include <stdio.h>

// Kernel in ra thông tin mỗi thread
__global__ void printThreadInfo()
{
    // Các biến built-in
    int bx = blockIdx.x;
    int by = blockIdx.y;

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int bdx = blockDim.x;
    int bdy = blockDim.y;

    int gx = bx * bdx + tx;
    int gy = by * bdy + ty;

    printf("BlockIdx: (%d,%d)  ThreadIdx: (%d,%d)  Global: (%d,%d)\n",
           bx, by,
           tx, ty,
           gx, gy);
}

int main()
{
    // Cấu hình grid và block
    dim3 grid(2, 3);      // 2 blocks theo X, 3 blocks theo Y
    dim3 block(4, 5);     // 4 threads theo X, 5 threads theo Y

    printf("Launching kernel with grid(%d,%d) block(%d,%d)\n",
           grid.x, grid.y, block.x, block.y);

    // Launch kernel
    printThreadInfo<<<grid, block>>>();

    // Đợi GPU xong
    cudaDeviceSynchronize();

    return 0;
}
