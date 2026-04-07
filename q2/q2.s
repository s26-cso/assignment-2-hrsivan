.section .bss
arr: .space 400000000

.section .data
printint: .asciz "%d "

.section .text
.global code

code:                                           # a0: number of args, a1: address of arg1
    addi sp, sp, -16                            # make space for
    sd ra, 0(sp)                                # return address

    addi s0, a0, -1                             # s0: array length (N)
    addi s1, a1, 8                              # s1 = address[a0] + 8 = arg[0]

    mv s2, zero                                 # iterator i = 0

    get_int_loop:
        bge s2, s0, end_int_loop                # end if i >= N

        slli t0, s2, 3                          # get offset = 8 * i
        add t1, t0, s1                          # get address of arg[i] = arg[0] + offset
        ld a0, 0(t1)                            # a0 = address[arg[i]]

        call atoi                               # call atoi

        slli t0, s2, 2                          # get offset
        la t1, arr                              # get address[arr[0]]
        add t2, t0, t1                          # get address[arr[i]]
        sw a0, 0(t2)                            # arr[i] = int[arg[i]]

        addi s2, s2, 1                          # i = i + 1

        j get_int_loop                          # loop

    end_int_loop:
    mv s2, s0                               # i = N
    addi s2, s2, -1                         # i = N - 1

    slli a0, s0, 2                          # a0 = 4 * N (bytes)
    call malloc

    mv s3, a0                               # s3 = base address of stack array

    slli a0, s0, 2                          # a0 = 4 * N (bytes)
    call malloc

    mv s4, a0                               # s4 = base address of result array

    mv s2, zero
    init_base_array:
        bge s2, s0, done_init               # if i >= N, done init

        slli t0, s2, 2                      # t0 = offset
        mv t1, s4                           # t1 = add[res[0]]
        add t2, t1, t0                      # t2 = add[res[i]]

        li t3, -1                           # t3 = -1
        sw t3, 0(t2)                        # res[i] = -1

        addi s2, s2, 1                      # i++

        j init_base_array                   # loop
    
    done_init:
    mv s2, s0                               # i = N
    addi s2, s2, -1                         # i = N - 1

    mv s5, zero                             # stack size (s)

    for_loop:
        blt s2, zero, end_for_loop          # if i < 0, end for loop

        while_loop:
            beqz s5, if_stack_empty

            addi t0, s5, -1                 # t0 = s - 1
            slli t1, t0, 2                  # t1 = offset on stack
            add t2, t1, s3                  # t2 = add[stack[s - 1]]
            lw t3, 0(t2)                    # t3 = stack[s - 1]

            slli t4, t3, 2                  # t4 = offset on array for stack[s - 1]
            la t5, arr                      # t5 = add[arr[0]]
            add t6, t5, t4                  # t6 = add[arr[stack[s - 1]]]
            lw t0, 0(t6)                    # t0 = arr[stack[s - 1]]

            slli t1, s2, 2                  # t1 = offset on array for i
            add t2, t5, t1                  # t2 = add[arr[i]]
            lw t1, 0(t2)                    # t1 = arr[i]

            bgt t0, t1, if_stack_empty

            addi s5, s5, -1                 # s--
            j while_loop

        if_stack_empty:
        beqz s5, push_to_stack
            slli t1, s2, 2                  # t1 = offset on res for i
            add t2, t1, s4                  # t2 = add[res[i]]
            sw t3, 0(t2)                    # res[i] = stack[s - 1]

        push_to_stack:
        slli t1, s5, 2                      # t1 = offset for s on stack
        add t2, t1, s3                      # t2 = add[stack[s]]
        sw s2, 0(t2)                        # stack[s] = i
        addi s5, s5, 1                      # s++


        addi s2, s2, -1                     # i--

        j for_loop

    end_for_loop:
    mv s2, zero                             # i = 0

    print_loop:
        bge s2, s0, end_print               # exit if i >= N

        la a0, printint                     # format string

        slli t0, s2, 2                      # get offset on res for i
        mv t1, s4                           # load base address for res
        add t2, t0, t1                      # get address[res[i]]
        lw a1, 0(t2)                        # load res[i]

        call printf

        addi s2, s2, 1                      # i++

        j print_loop
        
    end_print:
        ld ra, 0(sp)
        addi sp, sp, 16
