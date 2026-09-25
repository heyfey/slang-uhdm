// § objMacroParenArgsTrimmed160
`define D #2
module top (input logic clk, input logic a, input logic b, output logic q);
  always @(posedge clk) q <= `D ( a | b );
endmodule
