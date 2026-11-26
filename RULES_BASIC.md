# Luật trò chơi - bản tối thiểu

Tài liệu gốc cho thiết kế và hiện thực bản tối thiểu.

## 1. Bàn cờ

- B1. Bàn cờ có 8 hàng, đánh số 0..7 từ trên xuống, và 8 cột, đánh số 0..7 từ trái sang.
- B2. Ô (r, c) là ô tối khi r + c lẻ.
- B3. Chỉ dùng 32 ô tối. Ô sáng không bao giờ có quân.
- B4. Các ô tối được đánh số 1..32 từ trái sang phải, từ trên xuống dưới, mỗi hàng 4 ô:

```
 .  1  .  2  .  3  .  4
 5  .  6  .  7  .  8  .
 .  9  . 10  . 11  . 12
13  . 14  . 15  . 16  .
 . 17  . 18  . 19  . 20
21  . 22  . 23  . 24  .
 . 25  . 26  . 27  . 28
29  . 30  . 31  . 32  .
```

- B5. Từ số ô n sang tọa độ: r = (n-1) / 4, k = (n-1) mod 4, c = 2k+1 nếu r chẵn, c = 2k nếu r lẻ.
- B6. Từ tọa độ sang số ô: n = 4r + c/2 + 1 (chia nguyên), chỉ dùng khi (r, c) nằm trong bàn và là ô tối.
- B7. Góc nhìn cố định ở cả hai lượt: Black ở dưới, Red ở trên. Số ô không đổi theo lượt.

## 2. Quân cờ

- P1. Có hai phe: Black và Red.
- P2. Mỗi ô tối có một trong năm trạng thái: `0` trống, `b` pawn Black, `r` pawn Red, `B` king Black, `R` king Red.
- P3. Black tiến lên (r giảm), Red tiến xuống (r tăng).
- P4. Hàng phong cấp của Black là hàng 0 (ô 1-4), của Red là hàng 7 (ô 29-32).
- P5. Pawn chỉ đi và ăn theo hướng tiến. King đi và ăn được cả hai hướng.

## 3. Khởi đầu

- S1. Pawn Red ở ô 1-12, ô 13-20 trống, pawn Black ở ô 21-32.
- S2. Black đi trước.

## 4. Lượt đi

- T1. Hai phe đi luân phiên.
- T2. Người chơi phải đi trong lượt của mình, không được bỏ lượt.
- T3. Một lượt gồm một nước đi thường, hoặc một chuỗi gồm một hay nhiều cú ăn của cùng một quân.

## 5. Nước đi thường

- M1. Quân đi một ô theo đường chéo, theo hướng cho phép ở P5.
- M2. Ô đích phải nằm trong bàn và phải trống.
- M3. Nước đi thường vẫn hợp lệ khi đang có nước ăn.
- M4. King chỉ đi một ô (không có flying king).

## 6. Ăn quân

- C1. Quân ăn bằng cách nhảy chéo qua ô kề bên, theo hướng cho phép ở P5, và đáp xuống ô ngay sau đó.
- C2. Ô bị nhảy qua phải có quân của đối phương (pawn hoặc king).
- C3. Ô đáp phải nằm trong bàn và phải trống.
- C4. Sau cú ăn, quân bị nhảy qua bị loại khỏi bàn.

## 7. Phong cấp

- K1. Pawn dừng ở hàng phong cấp của phe mình thì thành king ngay, dù tới bằng nước đi thường hay cú ăn.
- K2. Pawn được phong cấp giữa chuỗi ăn thì cú ăn tiếp theo đã dùng hướng của king, kể cả ăn lùi.
- K3. Phong cấp không kết thúc lượt.

## 8. Chuỗi ăn

- CH1. Sau một cú ăn, nếu quân vừa nhảy còn ăn tiếp được thì bắt buộc phải ăn tiếp.
- CH2. Trong chuỗi, chỉ quân vừa nhảy được đi. Người chơi chỉ chọn ô đáp.
- CH3. Hướng được đổi giữa các cú ăn. Số cú ăn không giới hạn.
- CH4. Lượt kết thúc khi quân vừa nhảy không còn cú ăn nào.

## 9. Kết thúc ván

- W1. Sau một cú ăn, nếu đối phương không còn quân thì phe vừa ăn thắng.
- W2. Khi có phe thắng, chương trình in thông báo thắng rồi kết thúc.
- W3. Không có hòa.
- W4. Bản tối thiểu không phát hiện trường hợp một phe còn quân nhưng bị chặn hết nước đi. Khi đó ván không kết thúc.

## 10. Chuỗi in ra

- O1. Board in thành 8 dòng, mỗi dòng 8 ký hiệu cách nhau một dấu cách. Ô sáng in `-`, ô tối in theo P2.
- O2. Dòng lượt: `Black's turn.` hoặc `Red's turn.`
- O3. Lời nhắc, không xuống dòng: `Enter starting square: ` và `Enter landing square: `
- O4. Nước đi sai: `Not a valid move! Try again.`
- O5. Sau cú ăn, theo màu quân bị ăn: `Captured Black's piece.` hoặc `Captured Red's piece.`
- O6. Còn ăn tiếp được: `Chaining possible.`
- O7. Thắng: `Black wins!` hoặc `Red wins!`

## 11. Nhập và kiểm tra

- I1. Số ô được đọc bằng syscall 5 (read integer).
- I2. Nếu người chơi nhập thứ không phải số nguyên, MARS dừng chương trình. Bản tối thiểu chấp nhận điều này.
- V1. Chương trình hỏi đủ ô xuất phát s và ô đích t rồi mới kiểm tra.
- V2. Nước đi (s, t) hợp lệ khi: s trong khoảng 1..32, ô s có quân của phe đang đi, t trong khoảng 1..32, và quân ở s đi thường hoặc ăn được tới t.
- V3. Nếu nước đi không hợp lệ: in O4, rồi hỏi lại ô xuất phát. Không in lại board và dòng lượt.
- V4. Giữa chuỗi, t hợp lệ khi quân đang nhảy ăn được tới t.
- V5. Nếu t giữa chuỗi không hợp lệ: in O4, rồi hỏi lại `Enter landing square: `.

## 12. Trình tự một lượt

1. In board, trừ khi lượt trước kết thúc bằng cú ăn (board đã được in ngay sau cú ăn đó).
2. In dòng lượt, hỏi s và t, kiểm tra theo V1-V3.
3. Nếu là nước đi thường: di chuyển, phong cấp nếu có, đổi lượt, về bước 1.
4. Nếu là cú ăn:
   1. Thực hiện cú ăn, phong cấp nếu có.
   2. In O5, rồi in board.
   3. Nếu đối phương hết quân: in O7 và kết thúc.
   4. Nếu không còn ăn tiếp được: đổi lượt, về bước 1.
   5. Nếu còn: in O6, hỏi t, kiểm tra theo V4-V5, rồi về bước 4.1.

Ví dụ trong đề (mục 2.2):

```
Red's turn.
Enter starting square: 9
Enter landing square: 18
Captured Black's piece.
<board>
Chaining possible.
Enter landing square:
```
