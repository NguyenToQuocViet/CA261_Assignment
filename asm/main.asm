.include "macros.asm"

.data
# 10x10
#'*' border
#(r, c) -> idx (r+1)*10 + (c+1)
board:          .ascii "**********"
                .ascii "*-r-r-r-r*"
                .ascii "*r-r-r-r-*"
                .ascii "*-r-r-r-r*"
                .ascii "*0-0-0-0-*"
                .ascii "*-0-0-0-0*"
                .ascii "*b-b-b-b-*"
                .ascii "*-b-b-b-b*"
                .ascii "*b-b-b-b-*"
                .ascii "**********"

# UL UR DL DR
dirs:           .word -11, -9, 9, 11

turn:           .word 'b'   # 'b' / 'r', swap: xor 0x10
cnt_b:          .word 12
cnt_r:          .word 12

msg_turn_b:     .asciiz "Black's turn.\n"
msg_turn_r:     .asciiz "Red's turn.\n"
msg_start:      .asciiz "Enter starting square: "
msg_land:       .asciiz "Enter landing square: "
msg_invalid:    .asciiz "Not a valid move! Try again.\n"
msg_cap_b:      .asciiz "Captured Black's piece.\n"
msg_cap_r:      .asciiz "Captured Red's piece.\n"
msg_chain:      .asciiz "Chaining possible.\n"
msg_win_b:      .asciiz "Black wins!\n"
msg_win_r:      .asciiz "Red wins!\n"

.text
main:
	jal print_board
	li $v0, 10
	syscall

.include "functions.asm"
