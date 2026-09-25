// § objMacroParenArgsTrimmed160
`define D
module top (input logic clk, input logic a, input logic b, output logic q, output logic r);
  always_ff @(posedge clk) q <= `D (a & (b));
  always_ff @(posedge clk) r <= `D(  a  );
endmodule
