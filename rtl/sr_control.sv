//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024-2025 by Yuri Panchul & Mike Kuskov.
//
//  Modified in 2025 by Marat Mestnikov
//

`include "sr_cpu.svh"

module sr_control
(
    input        [ 6:0] cmdOp,
    input        [ 2:0] cmdF3,
    input        [ 6:0] cmdF7,
    input               aluZero,

    // expanded to 2 bits:
    output logic [ 1:0] pcSrc,
    output logic        regWrite,
    // new alu src
    output logic        aluSrcA,
    // expanded to 2 bits:
    output logic [ 1:0] aluSrcB,
    // expanded to 2 bits:
    output logic [ 1:0] wdSrc,
    // expanded to 4 bits:
    output logic [ 3:0] aluControl,
    output logic        invalid_instr
);
    logic          branch;
    logic          condZero;
    logic          jump;
    logic          jumpReg;

    always_comb
    begin
        if (jump)
            pcSrc = `PC_JAL;
        else if (jumpReg)
            pcSrc = `PC_JALR;
        else if (branch & (aluZero == condZero))
            pcSrc = `PC_BRANCH;
        else
            pcSrc = `PC_PLUS4;
    end

    always_comb
    begin
        branch        = 1'b0;
        condZero      = 1'b0;
        regWrite      = 1'b0;
        jump          = 1'b0;
        jumpReg       = 1'b0;
        aluSrcA       = `ALUA_RD1;
        aluSrcB       = `ALUB_RD2;
        wdSrc         = `WD_ALU;
        aluControl    = `ALU_ADD;
        invalid_instr = 1'b0;

        casez ({ cmdF7, cmdF3, cmdOp })
            // R-type
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  end
            // TODO: test
            { `RVF7_SLL,  `RVF3_SLL,  `RVOP_SLL  } : begin regWrite = 1'b1; aluControl = `ALU_SLL;  end
            { `RVF7_SLT,  `RVF3_SLT,  `RVOP_SLT  } : begin regWrite = 1'b1; aluControl = `ALU_SLT;  end
            { `RVF7_XOR,  `RVF3_XOR,  `RVOP_XOR  } : begin regWrite = 1'b1; aluControl = `ALU_XOR;  end
            { `RVF7_SRA,  `RVF3_SRA,  `RVOP_SRA  } : begin regWrite = 1'b1; aluControl = `ALU_SRA;  end
            { `RVF7_AND,  `RVF3_AND,  `RVOP_AND  } : begin regWrite = 1'b1; aluControl = `ALU_AND;  end

            // I-type
            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_ADD; end
            // TODO: test
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_SLL;  end
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_SLT;  end
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU} : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_SLTU; end
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_XOR;  end
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_SRL;  end
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_SRA;  end
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI  } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_OR;   end
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI } : begin regWrite = 1'b1; aluSrcB = `ALUB_IMM_I; aluControl = `ALU_AND;  end

            // U-type
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc = `WD_IMM_U; end
            // TODO: test
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_AUIPC} : begin regWrite = 1'b1; wdSrc = `WD_IMM_U; aluSrcA = `ALUA_PC; aluSrcB = `ALUB_IMM_U; end

            // B-type (condZero = 0 by default)
            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; aluControl = `ALU_SUB;  condZero = 1'b1; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB;  end
            { `RVF7_ANY,  `RVF3_BLT,  `RVOP_BLT  } : begin branch = 1'b1; aluControl = `ALU_SLT;  end
            { `RVF7_ANY,  `RVF3_BGE,  `RVOP_BGE  } : begin branch = 1'b1; aluControl = `ALU_SLT;  condZero = 1'b1; end
            { `RVF7_ANY,  `RVF3_BLTU, `RVOP_BLTU } : begin branch = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_ANY,  `RVF3_BGEU, `RVOP_BGEU } : begin branch = 1'b1; aluControl = `ALU_SLTU; condZero = 1'b1; end

            // J-type TODO: test
            { `RVF7_ANY,  `RVF3_JALR, `RVOP_JALR } : begin regWrite = 1'b1; jumpReg = 1'b1; wdSrc = `WD_PCPLUS4; end // I-type actually
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL  } : begin regWrite = 1'b1; jump = 1'b1;    wdSrc = `WD_PCPLUS4; end
            
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_ANY  } : begin invalid_instr = 1'b1; end
        endcase
    end

endmodule
