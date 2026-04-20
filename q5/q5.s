.section .data
filename: .asciz "input.txt"
mode: .asciz "rb"
yes: .asciz "Yes\n"
no: .asciz "No\n"

.section .text
.global main

main:
    addi sp, sp, -48                        # callee shall save:
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    sd s4, 0(sp)

    la a0, filename                         # load filename input.txt
    la a1, mode                             # load mode rb

    call fopen                              # fopen("input.txt", "rb")

    mv s0, a0                               # s0 has pointer to file (FP)

    mv a0, s0                               # a0 = FP (redundant)
    mv a1, zero                             # a1 = 0
    li a2, 2                                # a2 = 2, which app SEEK_END is a macro for

    call fseek                              # fseek(FP, 0, SEEK_END). FP at last position.

    mv a0, s0                               # a0 = FP

    call ftell                              # ftell(FP)

    addi s2, a0, -1                         # s2 has position of last character (r)
    mv s1, zero                             # s1 has position of first char (0) (l)

    loop:
        bge s1, s2, print_yes               # while l < r

        mv a0, s0                           # a0 = FP
        mv a1, s1                           # a1 = l
        li a2, 0                            # a2 = SEEK_SET (0)

        call fseek                          # FP at s + l

        mv a0, s0                           # a0 = FP

        call fgetc                          # get l char

        mv s3, a0                           # s3 = left letter

        mv a0, s0                           # a0 = FP
        mv a1, s2                           # a1 = r
        li a2, 0                            # SEEK_SET

        call fseek

        mv a0, s0

        call fgetc

        mv s4, a0                           # s4 = right letter

        addi s1, s1, 1                      # l++
        addi s2, s2, -1                     # r--

        beq s3, s4, loop                    # if c[l] == c[r] continue

    print_no:
        la a0, no
        call printf

        j end_prog

    print_yes:
        la a0, yes
        call printf

        j end_prog

    end_prog:
        mv a0, s0
        call fclose

        ld ra, 40(sp)
        ld s0, 32(sp)
        ld s1, 24(sp)
        ld s2, 16(sp)
        ld s3, 8(sp)
        ld s4, 0(sp)
        addi sp, sp, 48                        # callee shall restore

        ret
