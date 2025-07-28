        # Pseudo-instructions (I-type / U-type)
        li      t0, 123             # OK: within 12-bit signed range
        li      t1, 2047            # Max positive 12-bit signed
        li      t2, -2048           # Min 12-bit signed
        li      t3, 0x1000          # Forces LUI+ADDI

        # J-type: jump over a fake instruction
        jal     ra, next

        li      a0, 0xDEAD

        jal     ra, loop

        li      a0, 0xDEAD

next:
        # I-type
        addi    t4, zero, 42        # t4 = 42
        slli    t5, t4, 2           # t5 = t4 << 2
        srli    t6, t5, 1           # t6 = t5 >> 1
        andi    t0, t6, 0x0F        # t0 = t6 & 0x0F
        ori     t1, t0, 0xF0        # t1 = t0 | 0xF0
        xori    t2, t1, 0x0A        # t2 = t1 ^ 0x0A

        # R-type
        add     s0, t0, t1          # s0 = t0 + t1
        sub     s1, t2, t0          # s1 = t2 - t0
        or      s2, s0, s1          # s2 = s0 | s1
        and     s3, s2, t2          # s3 = s2 & t2
        xor     s4, s3, s1          # s4 = s3 ^ s1
        sll     s5, s4, t0          # s5 = s4 << (t0 & 0x1F)
        srl     s6, s5, t0          # s6 = s5 >> (t0 & 0x1F)

        # End program cleanly
        jalr    zero, 0(ra)         # return (ra set by earlier JAL)
        addi    zero, zero, 0       # NOP (optional)

loop:
        beqz    zero, loop