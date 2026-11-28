# args $a0 $a1, ret $v0 $v1

.text

# print_board: 8x8 inner, space-separated
print_board:
	la $t0, board
	addi $t0, $t0, 11       # idx 11 = (1, 1), doi 11 o la vi border *
	li $t1, 8               # row cnt

pb_row:
	li $t2, 8               # col cnt

pb_col:
	lb $a0, 0($t0)
	li $v0, 11
	syscall
	addi $t0, $t0, 1
	addi $t2, $t2, -1
	beq $t2, $zero, pb_eol  # last col: no space
	li $a0, ' '
	li $v0, 11
	syscall
	j pb_col

pb_eol:
	li $a0, '\n'
	li $v0, 11
	syscall
	addi $t0, $t0, 2        # skip border
	addi $t1, $t1, -1	# xuong hang
	bne $t1, $zero, pb_row
	jr $ra

# sq_to_idx: n -> idx, n out of 1..32 -> 0 (border)
sq_to_idx:
	li $v0, 0
	blt $a0, 1, si_end
	bgt $a0, 32, si_end
	addi $t0, $a0, -1
	srl $t1, $t0, 2         # r = (n-1) / 4
	andi $t2, $t0, 3        # k = (n-1) mod 4
	sll $t2, $t2, 1         # c = 2k
	andi $t3, $t1, 1
	bne $t3, $zero, si_calc
	addi $t2, $t2, 1        # r even: c = 2k+1

si_calc:
	mul $t1, $t1, 10        # idx = 10r + c + 11
	add $v0, $t1, $t2
	addi $v0, $v0, 11

si_end:
	jr $ra

# check_side: $a0 char, $a1 side -> 1 if pawn or king of side
check_side:
	li $v0, 1
	beq $a0, $a1, cs_end    # pawn
	addi $t0, $a1, -32
	beq $a0, $t0, cs_end    # king
	li $v0, 0

cs_end:
	jr $ra

# check_dir: $a0 piece, $a1 d -> 1 if d in piece's dirs range
check_dir:
	li $t0, 0               # lo
	li $t1, 3               # hi
	bne $a0, 'b', cd_red
	li $t1, 1               # b: 0..1

cd_red:
	bne $a0, 'r', cd_scan
	li $t0, 2               # r: 2..3

cd_scan:
	la $t2, dirs
	sll $t3, $t0, 2
	add $t2, $t2, $t3       # &dirs[lo]
	li $v0, 0

cd_loop:
	bgt $t0, $t1, cd_end
	lw $t3, 0($t2)
	beq $t3, $a1, cd_yes
	addi $t0, $t0, 1
	addi $t2, $t2, 4
	j cd_loop

cd_yes:
	li $v0, 1

cd_end:
	jr $ra

# move_piece: board[t] = board[s], board[s] = '0'
move_piece:
	la $t0, board
	add $t1, $t0, $a0
	add $t2, $t0, $a1
	lb $t3, 0($t1)
	sb $t3, 0($t2)
	li $t3, '0'
	sb $t3, 0($t1)
	jr $ra

# try_promote: b at row 1 / r at row 8 -> -32
try_promote:
	la $t0, board
	add $t0, $t0, $a0
	lb $t1, 0($t0)
	li $t2, 10
	div $a0, $t2
	mflo $t2                # row = idx / 10
	bne $t1, 'b', tp_red
	bne $t2, 1, tp_end
	j tp_up

tp_red:
	bne $t1, 'r', tp_end
	bne $t2, 8, tp_end

tp_up:
	addi $t1, $t1, -32
	sb $t1, 0($t0)

tp_end:
	jr $ra

# remove_piece: board[idx] = '0', opponent cnt - 1
remove_piece:
	la $t0, board
	add $t0, $t0, $a0
	li $t1, '0'
	sb $t1, 0($t0)
	lw $t1, turn
	xori $t1, $t1, 0x10     # opponent
	la $t2, cnt_b
	beq $t1, 'b', rp_dec
	la $t2, cnt_r

rp_dec:
	lw $t3, 0($t2)
	addi $t3, $t3, -1
	sw $t3, 0($t2)
	jr $ra

# can_capture: $a0 s, $a1 d -> 1 if s+d enemy and s+2d empty
can_capture:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	move $s0, $a0
	move $s1, $a1
	la $t0, board
	add $t0, $t0, $s0
	add $t0, $t0, $s1
	lb $a0, 0($t0)          # mid first: '*' stops before s+2d
	lw $a1, turn
	xori $a1, $a1, 0x10     # opponent
	jal check_side
	beq $v0, $zero, cc_end
	la $t0, board
	add $t0, $t0, $s0
	sll $t1, $s1, 1
	add $t0, $t0, $t1
	lb $t1, 0($t0)          # landing
	li $v0, 0
	bne $t1, '0', cc_end
	li $v0, 1

cc_end:
	lw $s1, 0($sp)
	lw $s0, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

# ask_square: $a0 prompt -> idx
ask_square:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $a0, $v0
	jal sq_to_idx
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# do_step: $a0 s, $a1 t -> move, promote
do_step:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	move $s0, $a1
	jal move_piece
	move $a0, $s0
	jal try_promote
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

# do_capture: $a0 s, $a1 t -> remove mid, move, promote
do_capture:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	move $s0, $a0
	move $s1, $a1
	add $a0, $s0, $s1
	sra $a0, $a0, 1         # mid = (s + t) / 2
	jal remove_piece
	move $a0, $s0
	move $a1, $s1
	jal move_piece
	move $a0, $s1
	jal try_promote
	lw $s1, 0($sp)
	lw $s0, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
