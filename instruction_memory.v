`timescale 1ns/1ns
// ============================================================
// instruction_memory.v - 16 x 8-bit combined program/data ROM
// ------------------------------------------------------------
// One shared memory holds BOTH the program instructions and the
// data they operate on (classic SAP-1 style). Every 8-bit word:
//   [7:4] = opcode     [3:0] = operand / address
//
// Demo program (full trace is in the chat explanation):
//   0: LDA 12   A = mem[12]           -> A = 5
//   1: ADD 13   A = A + mem[13]       -> A = 8
//   2: OUT      OUT = A               -> OUT = 8
//   3: SUB 14   A = A - mem[14]       -> A = 6
//   4: OUT      OUT = A               -> OUT = 6
//   5: JMP 7    PC = 7 (skips addr 6)
//   6: HLT      (filler, never reached)
//   7: OUT      OUT = A               -> OUT = 6 (proves jump worked)
//   8: HLT      stop
//  12: 5        (data)
//  13: 3        (data)
//  14: 2        (data)
// ============================================================

module instruction_memory (
    input  wire [3:0] address,
    output wire [7:0] data_out
);

    reg [7:0] mem [0:15];

    initial begin
        mem[0]  = 8'b0000_1100; // LDA 12
        mem[1]  = 8'b0001_1101; // ADD 13
        mem[2]  = 8'b0011_0000; // OUT
        mem[3]  = 8'b0010_1110; // SUB 14
        mem[4]  = 8'b0011_0000; // OUT
        mem[5]  = 8'b0100_0111; // JMP 7
        mem[6]  = 8'b1111_0000; // HLT (filler, unreachable)
        mem[7]  = 8'b0011_0000; // OUT
        mem[8]  = 8'b1111_0000; // HLT
        mem[9]  = 8'b1111_0000; // filler
        mem[10] = 8'b1111_0000; // filler
        mem[11] = 8'b1111_0000; // filler
        mem[12] = 8'b0000_0101; // data: 5
        mem[13] = 8'b0000_0011; // data: 3
        mem[14] = 8'b0000_0010; // data: 2
        mem[15] = 8'b0000_0000; // filler
    end

    assign data_out = mem[address]; // combinational read

endmodule
