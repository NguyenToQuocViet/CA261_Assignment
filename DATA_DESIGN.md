# Thiết kế dữ liệu - bản tối thiểu

Tài liệu thiết kế dữ liệu cho bản tối thiểu, dựa trên `RULES_BASIC.md`.

## 1. Bàn cờ trong bộ nhớ

- D1. Bàn cờ lưu trong mảng `board` gồm 100 byte, 10 hàng x 10 cột, theo thứ tự hàng.
- D2. Phần tử thứ idx của mảng nằm ở hàng idx / 10, cột idx mod 10.
- D3. Hàng 0, hàng 9, cột 0 và cột 9 của mảng là viền. Ô (r, c) của bàn cờ nằm ở idx = (r+1)*10 + (c+1). Viền làm mọi bước đi ra ngoài bàn rơi vào một ô `*`.
- D4. Mỗi phần tử lưu đúng ký tự được in ra:
  - `*` viền
  - `-` ô sáng
  - `0` ô tối trống
  - `b`, `r`, `B`, `R` theo P2
- D5. In board: in 8x8 ô bên trong mảng (hàng 1..8, cột 1..8), mỗi ô in ký tự của nó, các ô cách nhau một dấu cách.
- D6. Board khởi đầu khai báo sẵn trong `.data` bằng 10 dòng `.ascii`:

```
**********
*-r-r-r-r*
*r-r-r-r-*
*-r-r-r-r*
*0-0-0-0-*
*-0-0-0-0*
*b-b-b-b-*
*-b-b-b-b*
*b-b-b-b-*
**********
```

## 2. Đổi số ô sang idx

- D7. Từ số ô n: tính r, c theo B5, rồi idx = (r+1)*10 + (c+1).
- D8. Chỉ cần đổi chiều n sang idx. Chương trình không in số ô nên không cần chiều ngược lại.

Ví dụ:

```
n = 21: r = 5, k = 0, r lẻ nên c = 2k = 0,     idx = (5+1)*10 + (0+1) = 61
n = 17: r = 4, k = 0, r chẵn nên c = 2k+1 = 1, idx = (4+1)*10 + (1+1) = 52
```

## 3. Hướng đi

- D9. Bảng hướng: `dirs: .word -11, -9, 9, 11`, lần lượt là lên-trái, lên-phải, xuống-trái, xuống-phải.
- D10. Pawn Black dùng `dirs[0..1]`, pawn Red dùng `dirs[2..3]`, king dùng `dirs[0..3]`.
- D11. Đi thường theo hướng d: ô đích t = s + d.
- D12. Ăn theo hướng d: ô giữa m = s + d, ô đáp t = s + 2d.

## 4. Trạng thái game

- D13. Mỗi biến trạng thái là một nhãn `.word` trong `.data`:
  - `turn`: phe đang đi, `'b'` hoặc `'r'`, khởi đầu `'b'`.
  - `cnt_b`, `cnt_r`: số quân còn lại của mỗi phe, khởi đầu 12.
  - `chain`: idx của quân đang ăn chuỗi.
- D14. Đổi lượt: turn = turn xor 0x10 (`'b'` = 0x62, `'r'` = 0x72).
- D15. Ô thuộc phe p khi ký tự của ô bằng p (pawn) hoặc p - 32 (king). Phe đối phương là p xor 0x10.
- D16. Phong cấp: trừ 32 vào ký tự của ô (chữ thường thành chữ hoa).
- D17. Hàng phong cấp của Black có idx / 10 = 1, của Red có idx / 10 = 8.
