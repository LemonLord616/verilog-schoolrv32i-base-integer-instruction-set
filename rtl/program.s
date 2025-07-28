        # AUIPC test - place PC into t0
        auipc   t0, 0        # t0 = PC + 0

        # AUIPC with offset
        auipc   t1, 1        # t1 = PC + 0x1000

        # Subtract: t1 - t0 = 0x1000
        sub     t2, t1, t0   # Expect t2 = 0x1000 (4096)

        # Optional: insert a NOP
        addi    zero, zero, 0

        # Infinite loop to end simulation
end:
        j       end
