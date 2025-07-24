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

    logic [7:0] reg_A;
    logic [7:0] reg_B;
    logic [7:0] reg_C;
    logic [7:0] reg_D;

    logic [3:0] op_1;
    logic [1:0] input_a_1;
    logic [1:0] input_b_1;
    logic [1:0] output_1;
    
    
    logic [3:0] alu_op;
    logic [7:0] alu_out;
    logic [1:0] alu_sel_a;
    logic [1:0] alu_sel_b;

    alu alu(
        .A(reg_A),
        .B(reg_B),
        .C(reg_C),
        .D(reg_D),

        .sel_a(alu_sel_a),
        .sel_b(alu_sel_b),
        
        .op(alu_op),
        .out(alu_out)
    );

    
    always @(posedge clk) begin
        if (!rst_n) begin
            reg_A <= 0;
            reg_B <= 0;
            reg_C <= 0;
            reg_D <= 0;
            
            alu_op <= 0;
            alu_out <= 0;
            alu_sel_a <= 0;
            alu_sel_b <= 0;
            
            op_1 <= 0;
            input_a_1 <= 0;
            input_b_1 <= 0;
            output_1 <= 0;
        end else if (data_write) begin
            case (address)
                4'h0: reg_A <= data_in;
                4'h1: reg_B <= data_in;
                4'h2: reg_C <= data_in;
                4'h3: reg_D <= data_in;
                4'h4: op_1 <= data_in[3:0];
                4'h7: begin
                    input_a_1 <= data_in[1:0];
                    input_b_1 <= data_in[3:2];
                    output_1 <= data_in[5:4];
                      end
                default: ;
                alu_op <= op_1;
                alu_sel_a <= input_a_1;
                alu_sel_b <= input_b_1;
            endcase
        end
    end

    assign data_out =
        (address == 4'h0) ? reg_A :         // Read A
        (address == 4'h1) ? reg_B :         // Read B
        (address == 4'h2) ? reg_C :         // Read C
        (address == 4'h3) ? reg_D :         // Read D
        (address == 4'h4) ? {4'b0, op_1} : // Read Opcode
        (address == 4'h5) ? alu_out : // Read Result
        8'h00;


    
/* verilator lint_off UNUSEDSIGNAL */
wire [7:0] unused_ui_in = ui_in;  // Silence "unused" warning
/* verilator lint_on UNUSEDSIGNAL */

assign uo_out = 8'b0;             // Default output (or set only used bits)

    

endmodule


module alu(
    input logic [7:0] A,
    input logic [7:0] B,
    input logic [7:0] C,
    input logic [7:0] D,

    input logic [1:0] sel_a,
    input logic [1:0] sel_b,
    
    input logic [3:0] op,

    output logic [7:0] out
);

    logic [7:0] alu_a;
    logic [7:0] alu_b;
    
    always_comb begin
        case (sel_a)
            2'b00: alu_a = A;
            2'b01: alu_a = B;
            2'b10: alu_a = C;
            2'b11: alu_a = D;
        endcase

        case (sel_b)
            2'b00: alu_b = A;
            2'b01: alu_b = B;
            2'b10: alu_b = C;
            2'b11: alu_b = D;
        endcase
                
        case (op)
            4'b0000: out = alu_a + alu_b;
            4'b0001: out = alu_a - alu_b;
            default: out = 8'b0;
        endcase
    end


    
endmodule
