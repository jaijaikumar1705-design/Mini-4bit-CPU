`timescale 1ns/1ns
// ============================================================
// register_file.v - the CPU's working registers: A, B, OUT
// ------------------------------------------------------------
// A (accumulator)   : the main value the CPU is working on
// B (temp register) : holds the second operand during ADD/SUB
// OUT (output latch): holds whatever value was last sent to OUT
//
// Each register has its own data input and its own load-enable,
// so the control unit decides exactly which register gets
// written on any given clock edge -- no shared bus, no mux
// hazards to worry about inside this module.
// ============================================================

module register_file (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] a_in,
    input  wire [3:0] b_in,
    input  wire [3:0] out_in,
    input  wire       load_a,
    input  wire       load_b,
    input  wire       load_out,
    output reg  [3:0] reg_a,
    output reg  [3:0] reg_b,
    output reg  [3:0] reg_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_a   <= 4'b0000;
            reg_b   <= 4'b0000;
            reg_out <= 4'b0000;
        end else begin
            if (load_a)   reg_a   <= a_in;
            if (load_b)   reg_b   <= b_in;
            if (load_out) reg_out <= out_in;
        end
    end

endmodule
