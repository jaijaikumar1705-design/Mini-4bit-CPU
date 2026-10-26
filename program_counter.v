`timescale 1ns/1ns
// ============================================================
// program_counter.v - 4-bit Program Counter
// ------------------------------------------------------------
// Points at the address of the NEXT instruction to fetch.
// Three things can happen to it on a clock edge:
//   reset     -> PC = 0
//   pc_load   -> PC = pc_in   (used by JMP)
//   pc_enable -> PC = PC + 1  (normal fetch advance)
// pc_load takes priority over pc_enable if both were ever
// asserted at once (they never are in this design, but this
// keeps the module safe on its own).
// ============================================================

module program_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       pc_enable,
    input  wire       pc_load,
    input  wire [3:0] pc_in,
    output reg  [3:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 4'b0000;
        else if (pc_load)
            pc_out <= pc_in;
        else if (pc_enable)
            pc_out <= pc_out + 1'b1;
    end

endmodule
