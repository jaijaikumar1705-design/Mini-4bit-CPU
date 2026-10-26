// ============================================================
// tb_mini_cpu.v - testbench for mini_cpu_top
// ------------------------------------------------------------
// Generates clk/reset, lets the CPU run the built-in demo
// program until it halts, prints a cycle-by-cycle trace, dumps
// a VCD for GTKWave, and checks the final OUT value.
// ============================================================

`timescale 1ns/1ns

module tb_mini_cpu;

    reg clk;
    reg reset;

    wire [3:0] out_val;
    wire       halted;
    wire [3:0] pc_debug;
    wire [7:0] ir_debug;
    wire [3:0] a_debug;
    wire [3:0] b_debug;

    mini_cpu_top uut (
        .clk      (clk),
        .reset    (reset),
        .out_val  (out_val),
        .halted   (halted),
        .pc_debug (pc_debug),
        .ir_debug (ir_debug),
        .a_debug  (a_debug),
        .b_debug  (b_debug)
    );

    // 10 ns period clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_mini_cpu.vcd");
        $dumpvars(0, tb_mini_cpu);

        clk   = 0;
        reset = 1;
        #12;
        reset = 0;

        $display(" time |  PC |    IR    |  A |  B | OUT | halted");
        $monitor(" %3d  |  %2d | %b | %2d | %2d |  %2d  |   %0d",
                  $time, pc_debug, ir_debug, a_debug, b_debug, out_val, halted);

        wait (halted == 1'b1);
        #20;

        $display("\nFinal OUT = %0d (expected 6)", out_val);
        if (out_val == 4'd6)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

    // safety timeout in case the FSM never halts
    initial begin
        #2000;
        if (!halted) begin
            $display("TIMEOUT: CPU never halted");
            $finish;
        end
    end

endmodule
