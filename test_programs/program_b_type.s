        # Set up registers
        li      t0, 5              # t0 = 5
        li      t1, 5              # t1 = 5
        li      t2, 10             # t2 = 10
        li      t3, -1             # t3 = -1 (0xFFFFFFFF)
        li      t4, 0              # t4 = 0

        # BEQ: Equal -> take
        beq     t0, t1, label_beq_taken
        li      a0, 0x1111         # should be skipped
label_beq_taken:
        li      a1, 0xAAAA         # should execute

        # BNE: Not equal -> take
        bne     t0, t2, label_bne_taken
        li      a0, 0x2222         # should be skipped
label_bne_taken:
        li      a2, 0xBBBB         # should execute

        # BLT: t0 < t2 -> take
        blt     t0, t2, label_blt_taken
        li      a0, 0x3333         # should be skipped
label_blt_taken:
        li      a3, 0xCCCC         # should execute

        # BGE: t2 >= t0 -> take
        bge     t2, t0, label_bge_taken
        li      a0, 0x4444         # should be skipped
label_bge_taken:
        li      a4, 0xDDDD         # should execute

        # BLTU: t4 < t3 (0 < 0xFFFFFFFF) -> take (unsigned)
        bltu    t4, t3, label_bltu_taken
        li      a0, 0x5555         # should be skipped
label_bltu_taken:
        li      a5, 0xEEEE         # should execute

        # BGEU: t3 >= t4 (unsigned) -> take
        bgeu    t3, t4, label_bgeu_taken
        li      a0, 0x6666         # should be skipped
label_bgeu_taken:
        li      a6, 0xFFFF         # should execute

        # Exit
        li      a7, 10             # ECALL to exit (for simulators that use this)
        ecall # is not implemented yet
