.section .text
.global make_node
.global insert
.global get
.global getAtMost

make_node:                                  # a0: val
    addi sp, sp, -16                        # make space on stack for int val and ret add
    sd ra, 0(sp)                            # store return address on stack
    sw a0, 8(sp)                            # store val

    li a0, 24                               # 24 because 24 bytes
    call malloc                             # CALL malloc. Now a0 has pointer to address.

    ld ra, 0(sp)                            # load ret add back from stack
    lw t0, 8(sp)                            # load val to t0
    addi sp, sp, 16


    sw t0, 0(a0)                            # store int
    sd zero, 8(a0)                          # left child is NULL    
    sd zero, 16(a0)                         # right child is NULL

    ret

insert:                                     # a0: root, a1: val
    addi sp, sp, -32                        # make space for
    sd ra, 0(sp)                            # return address
    sd a0, 8(sp)                            # the root
    sw a1, 16(sp)                           # value to insert. rest 8 is padding.

    bnez a0, insert_child                   # if root is null get new node, else insert to a child
        lw a0, 16(sp)                       # load val to insert
        call make_node                      # call make node
        j end_insert                               

    insert_child:
    ld t0, 8(sp)                            # load root pointer
    lw t1, 0(t0)                            # load root value into t1
    lw t2, 16(sp)                           # load insert value into t2

    bge t2, t1, insert_right                # if less, insert in left child, else in right
        ld a0, 8(t0)                        # load left child as arg0
        mv a1, t2                           # move insert val into arg1
        call insert                         # call insert

        ld t0, 8(sp)                        # load og root
        sd a0, 8(t0)                        # assign returned node as its left child
        mv a0, t0                           # move into a0 the og root

        j end_insert

    insert_right:
        ld a0, 16(t0)                       # load right child as arg0
        mv a1, t2                           # move insert val to arg2
        call insert

        ld t0, 8(sp)                        # load og root
        sd a0, 16(t0)                       # assign its right child
        mv a0, t0                           # move into a0 og root

    end_insert:
        ld ra, 0(sp)
        addi sp, sp, 32

        ret

get:                                        # a0: root, a1: val
    get_loop:
        beqz a0, end_get                    # if searching null, return null

        lw t0, 0(a0)                        # load node val in t0
        beq t0, a1, end_get                 # if val is same as search, return!

        bgt a1, t0, get_right               # if val is lesser, get left, else get right
            ld a0, 8(a0)                    # load left child
            j get_loop
        
        get_right:
            ld a0, 16(a0)
            j get_loop

    end_get:
        ret

getAtMost:                                  # a0: val, a1: root
    addi sp, sp, -16                        # make space for
    sd ra, 0(sp)                            # ret address
    sd a1, 8(sp)                            # and root address

    bnez a1, check                          # if root is nULL, ret -1. else check
        li a0, -1                           # return -1
        j end_getAtMost
    
    check:
        lw t0, 0(a1)                        # load root val

        ble t0, a0, check_right             # if current val is >, search in left substree
            ld a1, 8(a1)                    # load left child

            ld ra, 0(sp)                    # restore ret add
            addi sp, sp, 16

            j getAtMost
        
        check_right:
            ld a1, 16(a1)                   # load right child in a1

            call getAtMost

            ld t1, 8(sp)                    # load root address

            li t3, -1

            bne a0, t3, ret_right_val       # if a0 == -1, return current root val
                lw a0, 0(t1)                # load current val
                
                j end_getAtMost
            
            ret_right_val:
                j end_getAtMost

    end_getAtMost:
        ld a0, 8(sp)
        ld ra, 0(sp)
        addi sp, sp, 16

        ret
