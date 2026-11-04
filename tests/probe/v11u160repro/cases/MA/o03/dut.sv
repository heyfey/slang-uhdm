// § objMacroParenArgsTrimmed160
`define D ~
module top (input logic clk, input logic [3:0] a, output logic [3:0] d);
  always_ff @(posedge clk) d <= `D (a & (a | 4'h1));
endmodule
