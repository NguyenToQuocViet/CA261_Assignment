# args $a0 $a1, ret $v0 $v1

.text

# print_board: 8x8 inner, space-separated
print_board:
        la   $t0, board
        addi $t0, $t0, 11       # idx 11 = (1, 1)
        li   $t1, 8             # row cnt
        
pb_row:
        li   $t2, 8             # col cnt
        
pb_col:
        lb   $a0, 0($t0)
        li   $v0, 11
        syscall
        addi $t0, $t0, 1
        addi $t2, $t2, -1
        beq  $t2, $zero, pb_eol # last col: no space
        li   $a0, ' '
        li   $v0, 11
        syscall
        j    pb_col
        
pb_eol:
        li   $a0, '\n'
        li   $v0, 11
        syscall
        addi $t0, $t0, 2        # skip border
        addi $t1, $t1, -1
        bne  $t1, $zero, pb_row
        jr   $ra
