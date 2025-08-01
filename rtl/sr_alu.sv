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

module sr_alu
(
    input        [31:0] srcA,
    input        [31:0] srcB,
    input        [ 3:0] oper,
    output              zero,
    output logic [31:0] result
);

    always_comb
        case (oper)
            default   : result =  srcA +   srcB;
            `ALU_ADD  : result =  srcA +   srcB;
            `ALU_OR   : result =  srcA |   srcB;
            `ALU_SRL  : result =  srcA >>  srcB [4:0];
            `ALU_SLTU : result = (srcA <   srcB) ? 32'd1 : 32'd0;
            `ALU_SUB  : result =  srcA -   srcB;
            `ALU_SLL  : result =  srcA <<  srcB [4:0];
            `ALU_SLT  : result = ($signed(srcA) <  $signed(srcB)) ? 32'd1 : 32'd0;
            `ALU_XOR  : result =  srcA ^   srcB;
            `ALU_SRA  : result =  srcA >>> srcB;
            `ALU_AND  : result =  srcA &   srcB;
        endcase

    assign zero = (result == '0);

endmodule
