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

    logic [7:0] data_out_logic;


    
    logic [7:0] A;
    logic [7:0] B;
    logic [7:0] C;
    logic [7:0] D;

    logic [3:0] op_1;
    logic [1:0] dest_1;
    logic [1:0] a_1;
    logic [1:0] b_1;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            A <= 0;
            B <= 0;
            C <= 0;
            D <= 0;

            op_1 <= 0;
            dest_1 <= 0;
            a_1 <= 0;
            b_1 <= 0;
        end else if (data_write) begin
            case (address)
                4'd0: A <= data_in;
                4'd1: B <= data_in;
                4'd2: C <= data_in;
                4'd3: D <= data_in;

                4'd4: op_1 <= data_in[3:0];
                4'd7: begin
                    a_1 <= data_in[1:0];
                    b_1 <= data_in[3:2];
                    dest_1 <= data_in[5:4];
                end
                default: ;
            endcase
        end
    end


        
always_comb begin
    case (address)
        4'd0: data_out_logic = A;
        4'd1: data_out_logic = B;
        4'd2: data_out_logic = C;
        4'd3: data_out_logic = D;
        4'd4: data_out_logic = {4'b0, op_1};       // Pad op_1 to 8 bits
        4'd5: data_out_logic = {6'b0, dest_1};     // Pad dest_1 to 8 bits
        4'd6: data_out_logic = {6'b0, a_1};        // Pad a_1 to 8 bits
        4'd7: data_out_logic = {6'b0, b_1};        // Pad b_1 to 8 bits
        default: data_out_logic = 8'b0;            // Explicit default
    endcase
end

assign data_out = data_out_logic;
            
/* verilator lint_off UNUSEDSIGNAL */
wire [7:0] unused_ui_in = ui_in;  // Silence "unused" warning
/* verilator lint_on UNUSEDSIGNAL */

assign uo_out = 8'b0;             // Default output (or set only used bits)

    

endmodule
