        #===============================================
        # Smoke‑test for all RV32I Load/Store instructions
        # (within 1 KiB), only real registers
        #===============================================

        #-------------------------
        # 1) SW / LW (word)
        #-------------------------
        addi    t0, zero, 291        # t0 = 0x00000123
        sw      t0, 0(zero)          # MEM[0] ← t0
        lw      t1, 0(zero)          # t1 ← MEM[0]
        bne     t1, t0, fail         # if t1!=t0 → fail

        #-------------------------
        # 2) SB / LB / LBU (byte)
        #-------------------------
        addi    t2, zero, -16        # t2 = 0xFFFFFFF0
        sb      t2, 1(zero)          # MEM[1] ← low‑byte of t2
        lb      s0, 1(zero)          # s0 ← sign‑ext(MEM[1])
        bne     s0, t2, fail         # if s0!=t2 → fail
        lbu     s1, 1(zero)          # s1 ← zero‑ext(MEM[1])
        addi    t3, zero, 240        # t3 = 240
        bne     s1, t3, fail         # if s1!=240 → fail

        #-------------------------
        # 3) SH / LH / LHU (half‑word)
        #-------------------------
        addi    t4, zero, -1000      # t4 = 0xFFFFFC18
        sh      t4, 2(zero)          # MEM[2..3] ← low‑half of t4
        lh      s2, 2(zero)          # s2 ← sign‑ext(MEM[2..3])
        bne     s2, t4, fail         # if s2!=t4 → fail
        lhu     s3, 2(zero)          # s3 ← zero‑ext(MEM[2..3])
        addi    t5, zero, 1000       # t5 = 1000
        bne     s3, t5, fail         # if s3!=1000 → fail

        #-------------------------
        # All load/store passed → jump to fibonacci
        #-------------------------
        j       fibonacci

fail:
        jal     zero, fail           # hang

#----------------------------------------
# RISC‑V Fibonacci (runs on success)
#----------------------------------------
fibonacci:
        addi    a0, zero, 0
        addi    t0, zero, 1

loop:
        add     t1, a0, t0
        addi    a0, t0, 0
        addi    t0, t1, 0
        beq     zero, zero, loop
