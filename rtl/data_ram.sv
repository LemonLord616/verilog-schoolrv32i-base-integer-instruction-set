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

module data_ram
#(
    parameter SIZE = 1024
)
(
    input         clk,

    input  [ 1:0] write_byte_en,
    input  [31:0] raddr,
    input  [31:0] waddr,
    input  [31:0] wdata,

    output [31:0] rdata
);
    logic [7:0] ram [0:SIZE - 1]; // single byte-addressable address space
    
    logic [31: 0] dump_debug;
    // initial $readmemh ("./rtl/data.hex", ram);

    always_ff @( posedge clk ) begin
        case (write_byte_en)
            `WBE_NO: ;          // nothing
            `WBE_W: begin       // word
                dump_debug     <= wdata;
                ram[waddr + 3] <= wdata[31:24];        
                ram[waddr + 2] <= wdata[23:16];        
                ram[waddr + 1] <= wdata[15: 8];        
                ram[waddr]     <= wdata[ 7: 0];        
            end
            `WBE_H: begin       // half word
                ram[waddr + 1] <= wdata[15: 8];
                ram[waddr]     <= wdata[ 7: 0];
            end
            `WBE_B: ram[waddr] <= wdata[ 7: 0]; // byte
        endcase
    end

    assign rdata = { ram [raddr + 3], ram [raddr + 2], ram [raddr + 1], ram [raddr] };


endmodule
