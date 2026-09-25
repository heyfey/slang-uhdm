// § objMacroParenArgsTrimmed160
`define F(x) (x)
module test(input clk, input a);
reg d;
always @(posedge clk)
    d <= `F(a) ^ (~a);
endmodule
