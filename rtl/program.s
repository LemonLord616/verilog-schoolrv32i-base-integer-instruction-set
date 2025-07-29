        # Prepare test value 0x0123 in t0
        addi    t0, zero, 0x123        # t0 ← 0x00000123

        # Store it at byte address 4
        sw      t0, 4(zero)            # MEM[4] ← 0x00000123

        # Load it back into t1
        lw      t1, 4(zero)            # t1 ← MEM[4]

        # Compare t1 against expected 0x0123 (in t2)
        addi    t2, zero, 0x123        # t2 ← 0x00000123
        beq     t1, t2, fibonacci      # if equal → fibonacci

# RISC-V fibonacci program
#
# Stanislav Zhelnio, 2020
# Amended by Yuri Panchul, 2024

fibonacci:

        mv      a0, zero
        li      t0, 1

loop:   add     t1, a0, t0
        mv      a0, t0
        mv      t0, t1
        beqz    zero, loop

# RISC-V factorial program
# Uncomment it when necessary

# factorial:
#
#         li      a0, 1
#         li      t0, 2
#
# loop:   mul     a0, a0, t0
#         addi    t0, t0, 1
#         b       loop
