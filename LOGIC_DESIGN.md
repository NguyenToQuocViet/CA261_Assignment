# Thiết kế logic - bản tối thiểu

Tài liệu chia chương trình thành các hàm, dựa trên `RULES_BASIC.md` và `DATA_DESIGN.md`.

## 1. Quy ước chung

- L1. Trong tài liệu này n là số ô (B4), còn s và t là idx (D3).
- L2. Tham số truyền qua `$a0`, `$a1`. Kết quả trả qua `$v0`, `$v1`. Hàm trả có hoặc không thì trả 1 hoặc 0.
- L3. Hàm gọi hàm khác phải lưu `$ra` lên stack, cùng các thanh ghi `$s` mà nó dùng.
- L4. Hàm cần bàn cờ thì tự lấy địa chỉ bằng `la`, không nhận qua tham số.
- L5. Các hàm xếp thành tầng cho dễ đọc. Hàm ở tầng trên dùng hàm ở tầng dưới, không có chiều ngược lại. Tầng không theo thứ tự chạy, thứ tự chạy ở mục 7.
- L6. Các thao tác một hai lệnh viết tại chỗ, không tách hàm:
  - phe đối phương: turn xor 0x10 (D15)
  - ô trống: ký tự của ô bằng `0`
  - đổi lượt: turn = turn xor 0x10 (D14)
  - thông báo theo phe (O2, O5, O7): mỗi thông báo có hai chuỗi, chọn theo turn
- L7. Với một nước đã hợp lệ, hiệu t - s lẻ là đi thường (±9, ±11), chẵn là ăn (±18, ±22).

## 2. Tầng 1

### `sq_to_idx`

- Vào: `$a0` = số ô n.
- Ra: `$v0` = idx.

1. n nằm ngoài 1..32 thì trả 0.
2. Ngược lại tính idx theo D7.

Idx 0 là ô viền `*`. Nhờ vậy số ô sai không cần kiểm tra riêng: làm ô xuất phát thì không qua được `check_side`, làm ô đích thì không phải ô trống.

### `check_side`

- Vào: `$a0` = ký tự của ô, `$a1` = phe (`b` hoặc `r`).
- Ra: `$v0` = 1 nếu ô có quân của phe đó.

1. Trả 1 khi ký tự bằng phe (pawn) hoặc bằng phe - 32 (king), theo D15.

### `check_dir`

- Vào: `$a0` = ký tự của quân, `$a1` = d.
- Ra: `$v0` = 1 nếu quân được đi theo d.

1. Lấy dải chỉ số trong `dirs` theo D10: `b` là 0..1, `r` là 2..3, `B` và `R` là 0..3.
2. Trả 1 nếu d bằng một phần tử trong dải.

Một lần kiểm tra loại được cả hiệu không phải hướng (ví dụ +5) lẫn hướng có thật nhưng quân không được đi (ví dụ +9 với `b`).

### `move_piece`

- Vào: `$a0` = s, `$a1` = t.
- Ra: không có.

1. Ô t nhận ký tự của ô s.
2. Ô s thành `0`.

### `try_promote`

- Vào: `$a0` = idx.
- Ra: không có.

1. Ký tự là `b` và idx / 10 = 1, hoặc ký tự là `r` và idx / 10 = 8, thì trừ 32 (K1, D16, D17).

### `remove_piece`

- Vào: `$a0` = idx của quân bị ăn.
- Ra: không có.

1. Ô idx thành `0` (C4).
2. Trừ 1 vào biến đếm của phe đối phương. Quân bị ăn luôn thuộc phe đối phương nên không cần đọc ô để biết phe.

### `print_board`

- Vào, ra: không có.

1. Với mỗi hàng 1..8 của mảng, in ký tự của cột 1..8, giữa hai ô một dấu cách, cuối hàng xuống dòng (D5, O1).

## 3. Tầng 2

### `can_capture`

- Vào: `$a0` = s, `$a1` = d.
- Ra: `$v0` = 1 nếu quân ở s ăn được theo d.
- Gọi: `check_side`.

1. Đọc ô giữa s + d (C1, D12). Không có quân của phe đối phương thì trả 0 (C2).
2. Đọc ô đáp s + 2d. Trả 1 nếu ô đáp trống (C3).

Ô giữa phải được đọc trước. Nếu ô giữa là `*` thì ô đáp có thể nằm ngoài mảng. Ví dụ: s = 12 (ô 1), d = -11 cho ô giữa idx 1 là `*`, hàm dừng ở bước 1 và không đọc idx -10. Thứ tự này thay cho mọi kiểm tra biên.

### `ask_square`

- Vào: `$a0` = địa chỉ chuỗi lời nhắc.
- Ra: `$v0` = idx.
- Gọi: `sq_to_idx`.

1. In lời nhắc.
2. Đọc n bằng syscall 5 (I1).
3. Trả `sq_to_idx(n)`.

### `do_step`

- Vào: `$a0` = s, `$a1` = t.
- Ra: không có.
- Gọi: `move_piece`, `try_promote`.

1. `move_piece(s, t)`.
2. `try_promote(t)`.

### `do_capture`

- Vào: `$a0` = s, `$a1` = t.
- Ra: không có.
- Gọi: `remove_piece`, `move_piece`, `try_promote`.

1. `remove_piece((s + t) / 2)`. Ô giữa (s + t) / 2 chính là s + d.
2. `move_piece(s, t)`.
3. `try_promote(t)`.

## 4. Tầng 3

### `can_capture_any`

- Vào: `$a0` = s.
- Ra: `$v0` = 1 nếu quân ở s còn ăn được theo ít nhất một hướng.
- Gọi: `check_dir`, `can_capture`.

1. Với i = 0..3, lấy d = dirs[i].
2. Trả 1 nếu `check_dir(ký tự ô s, d)` và `can_capture(s, d)` cùng trả 1.
3. Hết vòng thì trả 0.

Hàm đọc ký tự của ô s mỗi lần gọi, nên quân vừa phong cấp giữa chuỗi tự dùng hướng của king (K2).

### `is_legal`

- Vào: `$a0` = s, `$a1` = t.
- Ra: `$v0` = 1 nếu nước s → t hợp lệ (V2).
- Gọi: `check_side`, `check_dir`, `can_capture`.

1. Ô s không có quân của phe đang đi thì trả 0.
2. Tính diff = t - s.
3. diff lẻ: trả 1 nếu `check_dir(ký tự ô s, diff)` trả 1 và ô t trống (M1, M2).
4. diff chẵn: d = diff / 2, trả 1 nếu `check_dir(ký tự ô s, d)` và `can_capture(s, d)` cùng trả 1.

Ví dụ, lượt Black:

```
22 → 18 trên bàn khởi đầu: s = 63, t = 54, diff = -9 lẻ, -9 thuộc dải của b, idx 54 trống: hợp lệ
17 → 21, giả sử b ở ô 17 và ô 21 trống: s = 52, t = 61, diff = +9 lẻ, +9 không thuộc dải của b: sai
```

Ví dụ nhánh ăn nằm ở mục 7.

## 5. Tầng 4

### `ask_move`

- Vào: không có.
- Ra: `$v0` = s, `$v1` = t.
- Gọi: `ask_square`, `is_legal`.

1. Hỏi s bằng `Enter starting square: `.
2. Hỏi t bằng `Enter landing square: `.
3. `is_legal(s, t)` trả 1 thì trả s, t.
4. Ngược lại in O4 rồi về bước 1 (V1-V3).

### `ask_chain_landing`

- Vào: `$a0` = s, ô của quân đang ăn chuỗi.
- Ra: `$v0` = t.
- Gọi: `ask_square`, `is_legal`.

1. Hỏi t bằng `Enter landing square: `.
2. `is_legal(s, t)` trả 1 và t - s chẵn thì trả t. Điều kiện chẵn loại nước đi thường (L7).
3. Ngược lại in O4 rồi về bước 1 (V4, V5).

### `play_captures`

- Vào: `$a0` = s, `$a1` = t, cú ăn đầu tiên đã hợp lệ.
- Ra: `$v0` = 1 nếu ván kết thúc.
- Gọi: `do_capture`, `print_board`, `can_capture_any`, `ask_chain_landing`.

1. `do_capture(s, t)`.
2. In O5 theo phe đối phương.
3. `print_board`.
4. Biến đếm của phe đối phương bằng 0 thì in O7 theo phe đang đi, trả 1 (W1, W2).
5. `can_capture_any(t)` trả 0 thì trả 0 (CH4).
6. In O6, đặt s = t, t = `ask_chain_landing(s)`, về bước 1 (CH1-CH3).

## 6. Tầng 5

### `play_turn`

- Vào: không có.
- Ra: `$v0` = 1 nếu ván kết thúc.
- Gọi: `ask_move`, `do_step`, `print_board`, `play_captures`.

1. In O2 theo phe đang đi.
2. Lấy s, t từ `ask_move`.
3. t - s lẻ: `do_step(s, t)`, đổi lượt, `print_board`, trả 0.
4. t - s chẵn: `play_captures(s, t)`. Trả 1 thì trả 1. Trả 0 thì đổi lượt, trả 0.

### `main`

1. `print_board`.
2. Gọi `play_turn` cho tới khi nó trả 1.
3. Kết thúc bằng syscall 10.

## 7. Trình tự một lượt

Các bước ở mục 12 của RULES_BASIC do các hàm sau làm:

```
1    in board         main in lần đầu, play_turn in sau nước đi thường, play_captures in sau mỗi cú ăn
2    hỏi và kiểm tra  play_turn in dòng lượt, ask_move hỏi và gọi is_legal
3    nước đi thường   play_turn gọi do_step, đổi lượt
4.1  thực hiện ăn     do_capture
4.2  in O5, board     play_captures
4.3  hết quân         play_captures
4.4  hết ăn tiếp      can_capture_any trả 0, play_turn đổi lượt
4.5  ăn tiếp          play_captures in O6, ask_chain_landing hỏi t
```

Board được in ngay sau mỗi nước đi, nên đầu lượt không cần in lại.

Ví dụ chuỗi ăn trong đề, giả sử Red ở ô 9, Black ở ô 14, 23 và 32, lượt Red:

```
play_turn          in "Red's turn."
  ask_move         người chơi nhập 9, 18: s = 32, t = 54
    is_legal       diff = +22 chẵn, d = +11 thuộc dải của r
      can_capture  idx 43 là b, idx 54 là 0: hợp lệ
  play_captures    t - s chẵn nên là cú ăn
    do_capture     idx 43 thành 0, idx 54 thành r, cnt_b còn 2
                   in "Captured Black's piece.", in board
    can_capture_any(54)
                   d = -11, -9: không thuộc dải của r
                   d = +9: idx 63 là 0, không ăn được
                   d = +11: idx 65 là b, idx 76 là 0: còn ăn được
                   in "Chaining possible."
    ask_chain_landing(54)
                   người chơi nhập 27: t = 76, diff = +22 chẵn, hợp lệ
    do_capture     idx 65 thành 0, idx 76 thành r, cnt_b còn 1
                   in "Captured Black's piece.", in board
    can_capture_any(76)
                   d = +9: idx 85 là 0, không ăn được
                   d = +11: idx 87 là b, idx 98 là * không trống, không ăn được
                   trả 0
  đổi lượt sang Black
```
