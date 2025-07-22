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

module data_ram
#(
    parameter SIZE = 64
)
(
    input         clk,

    input         write_en,
    input  [31:0] raddr,
    input  [31:0] waddr,

    output [31:0] rdata,
    output [31:0] wdata
);
    logic [31:0] ram [0:SIZE - 1];
    
    // initial $readmemh ("./rtl/data.hex", ram);

    always_ff @( posedge clk ) begin
        if (write_en)
            ram[waddr] <= wdata;        
    end

    assign rdata = ram [raddr];


endmodule
