`timescale 1ns/1ns
// ============================================================
// instruction_decoder.v - Instruction Register + decode logic
// ------------------------------------------------------------
// Latches the fetched 8-bit word into the Instruction Register
// (IR) when load_ir pulses, then continuously splits it into:
//   opcode  = ir[7:4]
//   operand = ir[3:0]
// Keeping the IR here (instead of in register_file) keeps every
// "current instruction word" concern in one place.
// ============================================================

module instruction_decoder (
    input  wire       clk,
    input  wire       reset,
    input  wire       load_ir,
    input  wire [7:0] instruction_in,
    output wire [3:0] opcode,
    output wire [3:0] operand,
    output wire [7:0] ir_value   // exposed for debug / waveform viewing
);

    reg [7:0] ir;

    always @(posedge clk or posedge reset) begin
        if (reset)
            ir <= 8'h00;
        else if (load_ir)
            ir <= instruction_in;
    end

    assign opcode   = ir[7:4];
    assign operand  = ir[3:0];
    assign ir_value = ir;

endmodule
