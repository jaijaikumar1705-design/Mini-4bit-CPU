`timescale 1ns/1ns
// ============================================================
// control_unit.v - Fetch-Decode-Execute FSM
// ------------------------------------------------------------
// The "brain" that sequences every other module. It's a Moore
// machine: every control signal depends only on the CURRENT
// STATE (alu_sub is the one exception -- it also looks at
// opcode, just to pick add vs subtract during writeback).
//
// States:
//   S_FETCH    - PC on the address bus, load IR, PC++
//   S_DECODE   - opcode is now valid; branch to the right state
//   S_EXEC_LDA - operand on the address bus, load A from memory
//   S_EXEC_AL1 - operand on the address bus, load B from memory
//   S_EXEC_AL2 - ALU computes A+/-B, result written back to A
//   S_EXEC_OUT - A copied into the OUT register
//   S_EXEC_JMP - operand loaded into PC
//   S_HALT     - CPU stops here permanently
// ============================================================

module control_unit (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] opcode,
    output reg        pc_enable,
    output reg        pc_load,
    output reg        addr_sel,   // 0 = PC drives memory address, 1 = operand does
    output reg        load_ir,
    output reg        load_a,
    output reg        load_b,
    output reg        load_out,
    output reg        alu_sub,    // 0 = add, 1 = subtract
    output reg        a_sel,      // 0 = A loads from memory, 1 = A loads from ALU
    output reg        halted
);

    // Opcode map -- must match instruction_memory.v's encoding
    localparam OP_LDA = 4'b0000;
    localparam OP_ADD = 4'b0001;
    localparam OP_SUB = 4'b0010;
    localparam OP_OUT = 4'b0011;
    localparam OP_JMP = 4'b0100;
    localparam OP_HLT = 4'b1111;

    // FSM state encoding
    localparam S_FETCH    = 4'd0;
    localparam S_DECODE   = 4'd1;
    localparam S_EXEC_LDA = 4'd2;
    localparam S_EXEC_AL1 = 4'd3;
    localparam S_EXEC_AL2 = 4'd4;
    localparam S_EXEC_OUT = 4'd5;
    localparam S_EXEC_JMP = 4'd6;
    localparam S_HALT     = 4'd7;

    reg [3:0] state, next_state;

    // ---- state register ----
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_FETCH;
        else
            state <= next_state;
    end

    // ---- next-state logic ----
    always @(*) begin
        case (state)
            S_FETCH: next_state = S_DECODE;

            S_DECODE: begin
                case (opcode)
                    OP_LDA:  next_state = S_EXEC_LDA;
                    OP_ADD:  next_state = S_EXEC_AL1;
                    OP_SUB:  next_state = S_EXEC_AL1;
                    OP_OUT:  next_state = S_EXEC_OUT;
                    OP_JMP:  next_state = S_EXEC_JMP;
                    OP_HLT:  next_state = S_HALT;
                    default: next_state = S_HALT; // unknown opcode -> fail safe
                endcase
            end

            S_EXEC_LDA: next_state = S_FETCH;
            S_EXEC_AL1: next_state = S_EXEC_AL2;
            S_EXEC_AL2: next_state = S_FETCH;
            S_EXEC_OUT: next_state = S_FETCH;
            S_EXEC_JMP: next_state = S_FETCH;
            S_HALT:     next_state = S_HALT;
            default:    next_state = S_FETCH;
        endcase
    end

    // ---- output logic ----
    always @(*) begin
        // safe defaults every cycle so nothing accidentally latches
        pc_enable = 1'b0;
        pc_load   = 1'b0;
        addr_sel  = 1'b0;
        load_ir   = 1'b0;
        load_a    = 1'b0;
        load_b    = 1'b0;
        load_out  = 1'b0;
        alu_sub   = 1'b0;
        a_sel     = 1'b0;
        halted    = 1'b0;

        case (state)
            S_FETCH: begin
                addr_sel  = 1'b0; // PC drives the address bus
                load_ir   = 1'b1; // capture mem[PC] into IR
                pc_enable = 1'b1; // PC <- PC + 1
            end

            S_DECODE: begin
                // opcode/operand are already valid combinationally; nothing to write
            end

            S_EXEC_LDA: begin
                addr_sel = 1'b1; // operand drives the address bus
                a_sel    = 1'b0; // A gets memory data
                load_a   = 1'b1;
            end

            S_EXEC_AL1: begin
                addr_sel = 1'b1; // fetch the 2nd operand
                load_b   = 1'b1; // B <- mem[operand]
            end

            S_EXEC_AL2: begin
                alu_sub = (opcode == OP_SUB); // add or subtract
                a_sel   = 1'b1;               // A gets the ALU result
                load_a  = 1'b1;
            end

            S_EXEC_OUT: begin
                load_out = 1'b1; // OUT <- A
            end

            S_EXEC_JMP: begin
                pc_load = 1'b1;  // PC <- operand
            end

            S_HALT: begin
                halted = 1'b1;
            end
        endcase
    end

endmodule
