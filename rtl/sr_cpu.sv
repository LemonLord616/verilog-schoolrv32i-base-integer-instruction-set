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

module sr_cpu
(
    input           clk,               // clock
    input           rst,               // reset

    output  [31:0]  instr_addr,        // instruction memory address
    input   [31:0]  instr_data,        // instruction memory data

    output  [ 1:0]  write_byte_en,     // write data in ram on write_byte_en=1
    output  [31:0]  raddr,             // read ram address
    input   [31:0]  rdata,             // read ram data
    output  [31:0]  waddr,             // write ram address
    output  [31:0]  wdata,             // write ram data

    output          invalid_instr,

    input   [ 4:0]  debug_reg_addr, // debug access reg address
    output  [31:0]  debug_reg_data  // debug access reg data
);

    assign raddr = aluResult;
    assign waddr = aluResult;
    assign wdata = rd2;

    // control wires

    wire        aluZero;
    wire  [1:0] pcSrc;
    wire        regWrite;
    wire        aluSrcA;
    wire  [1:0] aluSrcB;
    wire  [1:0] wdSrc;
    wire  [3:0] aluControl;

    // instruction decode wires

    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immJ;
    wire [31:0] immS;

    // program counter

    logic [31:0] pc;
    logic [31:0] pcNext;
    wire [31:0] pcBranch  = pc + immB;
    wire [31:0] pcPlus4   = pc + 32'd4;
    wire [31:0] pcJump    = pc + immJ; // least significant bit is decoded as zero in decoder
    // TODO: recheck logic
    wire [31:0] pcJumpReg = (rd1 + immI) & ~32'b1; // least significant bit is zero

    always_comb
    begin
        unique case (pcSrc)
            `PC_PLUS4  : pcNext = pcPlus4;
            `PC_BRANCH : pcNext = pcBranch;
            `PC_JAL    : pcNext = pcJump;
            `PC_JALR   : pcNext = pcJumpReg;
        endcase
    end

    register_with_rst pc_r (clk, rst, pcNext, pc);

    // program memory access

    assign instr_addr = pc >> 2;
    wire [31:0] instr = instr_data;

    // instruction decode

    sr_decode id
    (
        .instr      ( instr       ),
        .cmdOp      ( cmdOp       ),
        .rd         ( rd          ),
        .cmdF3      ( cmdF3       ),
        .rs1        ( rs1         ),
        .rs2        ( rs2         ),
        .cmdF7      ( cmdF7       ),
        .immI       ( immI        ),
        .immB       ( immB        ),
        .immU       ( immU        ),
        .immJ       ( immJ        ),
        .immS       ( immS        )
    );

    // register file

    wire [31:0] debug_rd;
    wire [31:0] rd1;
    wire [31:0] rd2;
    logic [31:0] wd3;

    always_comb
    begin
        unique case (wdSrc)
            `WD_ALU     : wd3 = aluResult;
            `WD_IMM_U   : wd3 = immU;
            `WD_PCPLUS4 : wd3 = pcPlus4;
            `WD_MEM     : wd3 = rdata;
        endcase
    end

    sr_register_file rf
    (
        .clk        ( clk            ),
        .a1         ( rs1            ),
        .a2         ( rs2            ),
        .a3         ( rd             ),
        .rd1        ( rd1            ),
        .rd2        ( rd2            ),
        .wd3        ( wd3            ),
        .we3        ( regWrite       ),

        .dbg_addr   ( debug_reg_addr ),
        .dbg_data   ( debug_rd       )
    );

    // alu

    wire  [31:0] aluResult;
    wire  [31:0] srcA = aluSrcA == `ALUA_RD1 ? rd1 : pc;
    logic [31:0] srcB;

    always_comb
    begin
        unique case (aluSrcB)
            `ALUB_RD2   : srcB = rd2;
            `ALUB_IMM_I : srcB = immI;
            `ALUB_IMM_J : srcB = immJ;
            `ALUB_IMM_U : srcB = immU;
            `ALUB_IMM_S : srcB = immS;
        endcase
    end

    sr_alu alu
    (
        .srcA       ( srcA         ),
        .srcB       ( srcB        ),
        .oper       ( aluControl  ),
        .zero       ( aluZero     ),
        .result     ( aluResult   )
    );

    // control

    sr_control sm_control
    (
        .cmdOp         ( cmdOp         ),
        .cmdF3         ( cmdF3         ),
        .cmdF7         ( cmdF7         ),
        .aluZero       ( aluZero       ),
        .pcSrc         ( pcSrc         ),
        .regWrite      ( regWrite      ),
        .aluSrcA       ( aluSrcA       ),
        .aluSrcB       ( aluSrcB       ),
        .wdSrc         ( wdSrc         ),
        .aluControl    ( aluControl    ),
        .write_byte_en ( write_byte_en ),
        .invalid_instr ( invalid_instr )
    );

    // debug register access

    assign debug_reg_data = (debug_reg_addr != '0) ? debug_rd : pc;

endmodule
