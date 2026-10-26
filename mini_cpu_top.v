`timescale 1ns/1ns
// ============================================================
// mini_cpu_top.v - top-level wiring for the mini 4-bit CPU
// ------------------------------------------------------------
// Connects: program_counter, instruction_memory,
// instruction_decoder, register_file, alu, and control_unit.
//
// Two small muxes live here (they're too small to deserve their
// own file):
//   mem_address - PC during fetch, operand during the execute
//                 states that read memory (LDA / ADD / SUB)
//   a_in        - memory data during LDA, ALU result during
//                 ADD/SUB writeback
// ============================================================

module mini_cpu_top (
    input  wire       clk,
    input  wire       reset,
    output wire [3:0] out_val,   // value last sent to OUT
    output wire       halted,    // 1 once the CPU has executed HLT
    // debug/observability -- handy in GTKWave or on FPGA LEDs
    output wire [3:0] pc_debug,
    output wire [7:0] ir_debug,
    output wire [3:0] a_debug,
    output wire [3:0] b_debug
);

    wire [3:0] pc_val;
    wire [7:0] mem_data;
    wire [3:0] opcode, operand;
    wire [3:0] reg_a_val, reg_b_val;
    wire [3:0] alu_result;
    wire       alu_carry, alu_zero;

    wire pc_enable, pc_load, addr_sel;
    wire load_ir, load_a, load_b, load_out, alu_sub, a_sel;

    wire [3:0] mem_address = addr_sel ? operand    : pc_val;
    wire [3:0] a_in        = a_sel    ? alu_result  : mem_data[3:0];

    program_counter u_pc (
        .clk       (clk),
        .reset     (reset),
        .pc_enable (pc_enable),
        .pc_load   (pc_load),
        .pc_in     (operand),
        .pc_out    (pc_val)
    );

    instruction_memory u_imem (
        .address  (mem_address),
        .data_out (mem_data)
    );

    instruction_decoder u_decoder (
        .clk            (clk),
        .reset          (reset),
        .load_ir        (load_ir),
        .instruction_in (mem_data),
        .opcode         (opcode),
        .operand        (operand),
        .ir_value       (ir_debug)
    );

    register_file u_regs (
        .clk      (clk),
        .reset    (reset),
        .a_in     (a_in),
        .b_in     (mem_data[3:0]),
        .out_in   (reg_a_val),
        .load_a   (load_a),
        .load_b   (load_b),
        .load_out (load_out),
        .reg_a    (reg_a_val),
        .reg_b    (reg_b_val),
        .reg_out  (out_val)
    );

    alu u_alu (
        .a         (reg_a_val),
        .b         (reg_b_val),
        .sub       (alu_sub),
        .result    (alu_result),
        .carry_out (alu_carry),
        .zero      (alu_zero)
    );

    control_unit u_control (
        .clk       (clk),
        .reset     (reset),
        .opcode    (opcode),
        .pc_enable (pc_enable),
        .pc_load   (pc_load),
        .addr_sel  (addr_sel),
        .load_ir   (load_ir),
        .load_a    (load_a),
        .load_b    (load_b),
        .load_out  (load_out),
        .alu_sub   (alu_sub),
        .a_sel     (a_sel),
        .halted    (halted)
    );

    assign pc_debug = pc_val;
    assign a_debug  = reg_a_val;
    assign b_debug  = reg_b_val;

endmodule
