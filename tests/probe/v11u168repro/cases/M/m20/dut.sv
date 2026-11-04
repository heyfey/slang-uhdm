// § ppOutputLine166
`define A2(x, y) x & y
module top(input logic a, input logic b, output logic y);
  assign y = `A2(
     a,
     b) | a;
endmodule
