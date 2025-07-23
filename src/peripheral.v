/*
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
    reg [2:0] opcode;

    reg [15:0] reg_Result;
    always @(posedge clk) begin
        if (!rst_n) begin
        reg_A <= 8'h0;
        reg_B <= 8'h0;
        opcode <= 3'h0;
        reg_Result <= 16'h0;
        end else if (data_write) begin
            case (address)
                4'h0: reg_A <= data_in;
                4'h1: reg_B <= data_in;
                4'h4: opcode <= data_in[2:0];
                default: ;
            endcase
        end
    end


    assign data_out =
        (address == 4'h0) ? reg_A :         // Read A
        (address == 4'h1) ? reg_B :         // Read B
        (address == 4'h4) ? {5'b0, reg_Op} : // Read Opcode
        (address == 4'h5) ? reg_Result[7:0] : // Read Result Low
        (address == 4'h6) ? reg_Result[15:8] : // Read Result High
        8'h00;


    
/* verilator lint_off UNUSEDSIGNAL */
wire [7:0] unused_ui_in = ui_in;  // Silence "unused" warning
/* verilator lint_on UNUSEDSIGNAL */

assign uo_out = 8'b0;             // Default output (or set only used bits)

    

endmodule


module math_processor (
    input [7:0] a,
    input [7:0] b,
    input [2:0] opcode,
    output [15:0] result
);

       localparam 
        OP_ADD = 3'b000,
        OP_SUB = 3'b001,
        OP_MUL = 3'b010,
        OP_DIV = 3'b011,
        OP_AND = 3'b100,
        OP_OR  = 3'b101,
        OP_XOR = 3'b110;

    always @(*) begin
        case (opcode)
            OP_ADD: result = a + b;     // Addition
            OP_SUB: result = a - b;     // Subtraction
            OP_MUL: result = a * b;     // Multiplication (16-bit result)
            OP_DIV: result = a / b;     // Division (truncated)
            OP_AND: result = a & b;     // Bitwise AND
            OP_OR:  result = a | b;     // Bitwise OR
            OP_XOR: result = a ^ b;     // Bitwise XOR
            default: result = 16'b0;     // Default
        endcase
    end

    
endmodule
