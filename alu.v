`timescale 1ns/1ns

module alu (
    input  wire [3:0] a,          // first operand  (register A)
    input  wire [3:0] b,          // second operand (register B)
    input  wire       sub,        // 0 = add (A+B), 1 = subtract (A-B)
    output reg  [3:0] result,     // 4-bit result
    output reg        carry_out,  // carry (add) / borrow info (sub)
    output wire        zero        // 1 when result == 0 -- free extension point for JZ later
);

    reg [4:0] temp; // 5 bits so the carry/borrow bit isn't lost

    always @(*) begin
        if (sub)
            temp = {1'b0, a} - {1'b0, b};
        else
            temp = {1'b0, a} + {1'b0, b};

        result    = temp[3:0];
        carry_out = temp[4];
    end

    assign zero = (result == 4'b0000);

endmodule
