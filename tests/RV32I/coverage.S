    .section .text
    .globl _start
_start:
    lui   x1, 0x12345
    auipc x2, 0
    addi  x3, x0, -5
    addi  x4, x0, 3
    add   x5, x3, x4
    sub   x6, x4, x3
    and   x7, x1, x2
    or    x8, x3, x4
    xor   x9, x3, x4
    addi  x10, x0, 2
    sll   x11, x4, x10
    srl   x12, x1, x10
    sra   x13, x3, x10
    slt   x14, x3, x4
    sltu  x15, x3, x4
    slli  x16, x4, 2
    srli  x17, x1, 2
    srai  x18, x3, 2
    slti  x19, x3, 0
    sltiu x20, x3, 1
    xori  x21, x4, 7
    ori   x22, x4, 8
    andi  x23, x4, 1

    addi  x24, x0, 1
    addi  x25, x0, 2
    bne   x24, x25, bne_ok
    addi  x26, x0, 99
bne_ok:
    blt   x3, x4, blt_ok
    addi  x26, x0, 98
blt_ok:
    bge   x4, x3, bge_ok
    addi  x26, x0, 97
bge_ok:
    bltu  x3, x4, bltu_ok
    addi  x26, x0, 96
bltu_ok:
    bgeu  x4, x3, bgeu_ok
    addi  x26, x0, 95
bgeu_ok:
    addi  x26, x0, 26

    jal   x27, jal_ok
    addi  x26, x0, 94
jal_ok:
    addi  x26, x0, 27

    addi  x28, x0, -128
    sb    x28, 600(x0)
    lb    x29, 600(x0)
    lbu   x30, 600(x0)
    addi  x31, x0, 291
    sh    x31, 604(x0)
    lh    x1, 604(x0)
    lhu   x2, 604(x0)

    sw    x1, 512(x0)
    sw    x2, 516(x0)
    sw    x5, 520(x0)
    sw    x6, 524(x0)
    sw    x7, 528(x0)
    sw    x8, 532(x0)
    sw    x9, 536(x0)
    sw    x11, 540(x0)
    sw    x13, 544(x0)
    sw    x14, 548(x0)
    sw    x15, 552(x0)
    sw    x16, 556(x0)
    sw    x18, 560(x0)
    sw    x19, 564(x0)
    sw    x20, 568(x0)
    sw    x21, 572(x0)
    sw    x22, 576(x0)
    sw    x23, 580(x0)
    sw    x26, 584(x0)
    sw    x27, 588(x0)
    sw    x29, 592(x0)
    sw    x30, 596(x0)
    sw    x31, 600(x0)
    ecall