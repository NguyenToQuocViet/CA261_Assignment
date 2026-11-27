# print string, clobber $v0 $a0
.macro print_str(%label)
        li   $v0, 4
        la   $a0, %label
        syscall
.end_macro
