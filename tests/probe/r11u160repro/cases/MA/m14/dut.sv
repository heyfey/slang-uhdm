// § objMacroParenArgsTrimmed160
`define W 8
module test(input [7:0] a, output [7:0] y);
  assign y = a;
  wire [`W -1:0] z = a;
endmodule
