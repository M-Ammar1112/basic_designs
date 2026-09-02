    .section .text
    .globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 7
    add  x3, x1, x2
    sub  x4, x3, x1
    sw   x3, 256(x0)
    sw   x4, 260(x0)
    addi x5, x0, 1
    addi x6, x0, 1
    beq  x5, x6, branch_ok
    addi x7, x0, 99
branch_ok:
    addi x7, x0, 9
    sw   x7, 264(x0)
    lw   x8, 256(x0)
    slli x8, x8, 2
    sw   x8, 268(x0)
    ecall