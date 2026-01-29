# 📘 Exercise: Print Thread Positions in 2D Grid and 2D Blocks

## Objective

Write a CUDA program to:
- ✔ Launch a 2D grid
- ✔ Each block is 2D
- ✔ Each thread prints:
  - `blockIdx.x`, `blockIdx.y`
  - `threadIdx.x`, `threadIdx.y`
  - `global_x`, `global_y`

This exercise will help you understand:
- ✔ Where a thread is located within its block
- ✔ Where a block is located within the grid
- ✔ How to calculate the global index of each thread

## 📍 Exercise Requirements

### Configuration

Use the following configuration:

```cpp
dim3 grid(2, 3);   // 2 blocks along X, 3 blocks along Y
dim3 block(4, 5);  // 4 threads along X, 5 threads along Y
```

**Total threads** = 2 × 3 × 4 × 5 = **120 threads** executing the kernel.

### Kernel Logic

Inside the kernel, each thread should calculate its global position:

```cpp
global_x = blockIdx.x * blockDim.x + threadIdx.x;
global_y = blockIdx.y * blockDim.y + threadIdx.y;
```

These are the global indices of the thread in the 2D grid.

### Output Format

Each thread should print its information using the following format:

```
Block: (bx, by) Thread: (tx, ty) --> Global: (gx, gy)
```

### Host Code

- Call the kernel with the specified grid and block dimensions
- Use `cudaDeviceSynchronize()` to ensure the host waits for the kernel to complete

## Expected Learning Outcomes

After completing this exercise, you will:

1. Understand the relationship between `blockIdx`, `threadIdx`, and `blockDim`
2. Know how to calculate global thread indices in 2D grids
3. Visualize the hierarchical structure of CUDA threads: Grid → Blocks → Threads
4. Practice basic CUDA kernel launching and synchronization

## Implementation Tips

- Remember that CUDA thread indexing starts from 0
- The output may appear in any order since threads execute in parallel
- Use `printf()` inside the kernel for device-side output
- Make sure to check for CUDA errors after kernel launch

## Example Output (Partial)

```
Block: (0, 0) Thread: (0, 0) --> Global: (0, 0)
Block: (0, 0) Thread: (1, 0) --> Global: (1, 0)
Block: (0, 0) Thread: (2, 0) --> Global: (2, 0)
Block: (1, 0) Thread: (0, 0) --> Global: (4, 0)
Block: (1, 0) Thread: (1, 0) --> Global: (5, 0)
...
```

Note: The actual output order will vary due to parallel execution.

## Bonus Challenge

Try to answer these questions after running your program:

1. What is the global position of the thread at Block(1, 2), Thread(3, 4)?
2. How would you modify the kernel to print only threads in the first row (global_y = 0)?
3. What happens if you change the grid dimensions but keep the same block dimensions?
