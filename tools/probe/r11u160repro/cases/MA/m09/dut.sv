// § objMacroParenArgsTrimmed160
`define W 4
module test(input clk, input [7:0] a, output [7:0] y);
  assign y = a + `W (2);
endmodule
