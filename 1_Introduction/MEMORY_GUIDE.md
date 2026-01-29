# Hướng Dẫn Quản Lý Bộ Nhớ CUDA

## Câu hỏi của bạn: "Tại sao phải dùng con trỏ?"

### TL;DR (Tóm tắt nhanh)
- ❌ **KHÔNG thể** khai báo mảng tĩnh `int a[N]` rồi dùng trên GPU
- ✅ **Phải dùng con trỏ** vì GPU và CPU có bộ nhớ riêng biệt
- ✅ **Có cách đơn giản hơn**: Unified Memory (`cudaMallocManaged`)

---

## 3 Cách Quản Lý Bộ Nhớ

### ❌ CÁCH 1: KHÔNG THỂ LÀM ĐƯỢC

```cpp
int a[8] = {0, 1, 2, 3, 4, 5, 6, 7};  // Mảng trên CPU
add_vectors<<<1, 8>>>(a, b, c, 8);    // ❌ LỖI!
```

**Tại sao không được?**
```
┌─────────────────────────────────────────┐
│  CPU (RAM)              GPU (VRAM)      │
│  ──────────            ──────────       │
│  int a[8]    ✗─────────✗  ???          │
│  địa chỉ     không truy                 │
│  0x1000      cập được!                  │
└─────────────────────────────────────────┘
```

- GPU và CPU có **không gian địa chỉ riêng biệt**
- Mảng `int a[8]` nằm trên RAM → GPU **không thấy** địa chỉ này

---

### ✅ CÁCH 2: MANUAL MEMORY (Như file gốc của bạn)

**File:** `add_vector.cu`

```cpp
// Bước 1: Khai báo mảng trên CPU
int h_a[N], h_b[N], h_c[N];

// Bước 2: Khai báo CON TRỎ trỏ đến GPU
int *d_a, *d_b, *d_c;

// Bước 3: Cấp phát bộ nhớ trên GPU
cudaMalloc(&d_a, N * sizeof(int));

// Bước 4: Copy CPU → GPU
cudaMemcpy(d_a, h_a, N * sizeof(int), cudaMemcpyHostToDevice);

// Bước 5: Chạy kernel
add_vectors<<<gridSize, blockSize>>>(d_a, d_b, d_c, N);

// Bước 6: Copy GPU → CPU
cudaMemcpy(h_c, d_c, N * sizeof(int), cudaMemcpyDeviceToHost);

// Bước 7: Giải phóng
cudaFree(d_a);
```

**Giải thích con trỏ:**
```
┌───────────────────────────────────────────────────┐
│  CPU (RAM)              GPU (VRAM)                │
│  ──────────            ──────────                 │
│  h_a[N] = {0,1,2,..}   [bộ nhớ GPU]              │
│                         ↑                          │
│  d_a = 0x5000 ─────────┘                          │
│  (con trỏ trên CPU     (địa chỉ thật trên GPU)   │
│   chứa địa chỉ GPU)                               │
└───────────────────────────────────────────────────┘
```

**Ưu điểm:**
- ✅ Kiểm soát hoàn toàn
- ✅ Hiệu năng tối ưu cho dữ liệu lớn
- ✅ Tốt cho production

**Nhược điểm:**
- ❌ Phức tạp (8 bước!)
- ❌ Dễ quên copy hoặc free
- ❌ Nhiều code boilerplate

---

### ✅ CÁCH 3: UNIFIED MEMORY (Đơn giản nhất!)

**File:** `add_vector_unified.cu`

```cpp
// Bước 1: Cấp phát Unified Memory
int *a, *b, *c;
cudaMallocManaged(&a, N * sizeof(int));
cudaMallocManaged(&b, N * sizeof(int));
cudaMallocManaged(&c, N * sizeof(int));

// Bước 2: Gán giá trị TRỰC TIẾP (không cần copy!)
for (int i = 0; i < N; i++) {
    a[i] = i;
    b[i] = i * 2;
}

// Bước 3: Chạy kernel (CUDA tự động chuyển dữ liệu)
add_vectors<<<gridSize, blockSize>>>(a, b, c, N);

// Bước 4: Đợi xong
cudaDeviceSynchronize();

// Bước 5: Đọc kết quả TRỰC TIẾP (CUDA tự động chuyển về)
for (int i = 0; i < N; i++) {
    printf("%d\n", c[i]);
}

// Bước 6: Giải phóng
cudaFree(a);
```

**Cách hoạt động:**
```
┌─────────────────────────────────────────────┐
│    UNIFIED MEMORY (Bộ nhớ hợp nhất)        │
│    ──────────────────────────              │
│                                             │
│    CPU truy cập ←─── [Data] ───→ GPU       │
│    (CUDA tự động      a[N]     truy cập    │
│     di chuyển)                 (CUDA tự    │
│                                 động       │
│                                 di chuyển) │
└─────────────────────────────────────────────┘
```

**Ưu điểm:**
- ✅ **ĐƠN GIẢN** nhất (chỉ 6 bước thay vì 8)
- ✅ Không cần `cudaMemcpy`
- ✅ Ít lỗi hơn
- ✅ Code gọn gàng

**Nhược điểm:**
- ❌ Có thể chậm hơn với dữ liệu lớn (GB)
- ❌ Cần GPU Pascal trở lên (GTX 10xx+)

---

## So Sánh Cụ Thể

| Tiêu chí | Manual Memory | Unified Memory |
|----------|--------------|----------------|
| **Số bước** | 8 bước | 6 bước |
| **Cần cudaMemcpy?** | ✅ Có | ❌ Không |
| **Dễ viết?** | ❌ Khó | ✅ Dễ |
| **Dễ sai?** | ✅ Dễ sai | ❌ Khó sai |
| **Hiệu năng** | Nhanh nhất | Nhanh (có thể chậm hơn chút) |
| **Dùng khi nào?** | Production, dữ liệu lớn | Học tập, prototype |

---

## Chạy Các Ví Dụ

### Cách 1: Chạy từng file

```bash
# Ví dụ gốc (Manual Memory)
nvcc add_vector.cu -o add_vector
./add_vector

# Unified Memory
nvcc add_vector_unified.cu -o add_vector_unified
./add_vector_unified

# So sánh đầy đủ
nvcc memory_comparison.cu -o memory_comparison
./memory_comparison
```

### Cách 2: Chạy script tự động

```bash
chmod +x compile_and_run.sh
./compile_and_run.sh
```

---

## Kết Luận

### Tại sao phải dùng con trỏ?
Vì GPU và CPU có bộ nhớ riêng biệt, không thể dùng mảng tĩnh trực tiếp!

### Nên dùng cách nào?
- 🎓 **Học tập:** Unified Memory (đơn giản, dễ hiểu)
- 🚀 **Dự án thực tế:** Manual Memory (tối ưu, kiểm soát tốt)
- ❌ **Mảng tĩnh:** KHÔNG dùng được!

### Các file trong thư mục này:
- `add_vector.cu` - Ví dụ gốc (Manual Memory)
- `add_vector_unified.cu` - Ví dụ Unified Memory
- `memory_comparison.cu` - So sánh cả 3 cách
- `compile_and_run.sh` - Script compile tự động
- `MEMORY_GUIDE.md` - Tài liệu này

---

## Tài Liệu Tham Khảo
- [CUDA Unified Memory](https://developer.nvidia.com/blog/unified-memory-cuda-beginners/)
- [CUDA C Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
