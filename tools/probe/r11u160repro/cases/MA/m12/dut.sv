// § objMacroParenArgsTrimmed160
`define D #1
module test(input clk, input a, input b);
reg d;
always @(posedge clk)
    d <= `D (a & b) ^ a;
endmodule
