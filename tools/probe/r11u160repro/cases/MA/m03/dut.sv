// § objMacroParenArgsTrimmed160
`define D #12
module test(input clk);
reg d;
always @(posedge clk)
    d <= `D (~d);
endmodule
