# args $a0 $a1, ret $v0 $v1

.text

# print_board: 8x8 inner, space-separated
print_board:
	la $t0, board
	addi $t0, $t0, 11       # idx 11 = (1, 1)
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
	addi $t1, $t1, -1
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
