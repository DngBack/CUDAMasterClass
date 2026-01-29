#!/bin/bash

echo "========================================"
echo "  COMPILE VÀ CHẠY CÁC VÍ DỤ CUDA"
echo "========================================"

# Compile ví dụ gốc
echo ""
echo "[1] Compile add_vector.cu (Manual Memory)..."
nvcc add_vector.cu -o add_vector
if [ $? -eq 0 ]; then
    echo "✓ Compile thành công!"
    echo "Chạy:"
    ./add_vector
else
    echo "✗ Compile thất bại!"
fi

# Compile ví dụ Unified Memory
echo ""
echo "[2] Compile add_vector_unified.cu (Unified Memory)..."
nvcc add_vector_unified.cu -o add_vector_unified
if [ $? -eq 0 ]; then
    echo "✓ Compile thành công!"
    echo "Chạy:"
    ./add_vector_unified
else
    echo "✗ Compile thất bại!"
fi

# Compile ví dụ so sánh
echo ""
echo "[3] Compile memory_comparison.cu (So sánh đầy đủ)..."
nvcc memory_comparison.cu -o memory_comparison
if [ $? -eq 0 ]; then
    echo "✓ Compile thành công!"
    echo "Chạy:"
    ./memory_comparison
else
    echo "✗ Compile thất bại!"
fi

echo ""
echo "========================================"
echo "  HOÀN TẤT!"
echo "========================================"
