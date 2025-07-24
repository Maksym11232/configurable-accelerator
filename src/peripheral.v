+/*
 * Copyright (c) 2025 Maksym Podgorski
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Change the name of this module to something that reflects its functionality and includes your name for uniqueness
// For example tqvp_yourname_spi for an SPI peripheral.
// Then edit tt_wrapper.v line 38 and change tqvp_example to your chosen module name.
module accelerator (
    input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input         rst_n,        // Reset_n - low to reset.

    input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                                // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.

    output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                // Note that uo_out[0] is normally used for UART TX.

    input [3:0]   address,      // Address within this peripheral's address space

    input         data_write,   // Data write request from the TinyQV core.
    input [7:0]   data_in,      // Data in to the peripheral, valid when data_write is high.
    
    output [7:0]  data_out      // Data out from the peripheral, set this in accordance with the supplied address
);

    reg [7:0] reg_A;
    reg [7:0] reg_B;
    reg [7:0] reg_C;
    reg [7:0] reg_D;
    
    reg [3:0] reg_Op;

    reg [7:0] reg_Result;


    logic [7:0] alu_a;
    logic [7:0] alu_b;
    logic [3:0] alu_op;
    logic [7:0] alu_out;

    alu alu(
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .out(alu_out)
    );

    
    always @(posedge clk) begin
        if (!rst_n) begin
            reg_A <= 0;
            reg_B <= 0;
            reg_C <= 0;
            reg_D <= 0;
            reg_Op <= 0;
            reg_Result <= 0;
        end else if (data_write) begin
            case (address)
                4'h0: reg_A <= data_in;
                4'h1: reg_B <= data_in;
                4'h2: reg_C <= data_in;
                4'h3: reg_D <= data_in;
                4'h4: reg_Op <= data_in[3:0];
                default: ;
            endcase
            reg_Result <= alu_out;
        end
    end

    assign data_out =
        (address == 4'h0) ? reg_A :         // Read A
        (address == 4'h1) ? reg_B :         // Read B
        (address == 4'h2) ? reg_C :         // Read A
        (address == 4'h3) ? reg_D :         // Read B
        (address == 4'h4) ? {4'b0, reg_Op} : // Read Opcode
        (address == 4'h5) ? reg_Result : // Read Result Low
        8'h00;


    
/* verilator lint_off UNUSEDSIGNAL */
wire [7:0] unused_ui_in = ui_in;  // Silence "unused" warning
/* verilator lint_on UNUSEDSIGNAL */

assign uo_out = 8'b0;             // Default output (or set only used bits)

    

endmodule


module alu(
    input logic [7:0] a,
    input logic [7:0] b,
    input logic [3:0] op,
    output logic [7:0] out
);

    always_comb begin
        case (op)
            4'b0000: out = a + b;
            4'b0001: out = a - b;
        endcase
    end


    
endmodule
