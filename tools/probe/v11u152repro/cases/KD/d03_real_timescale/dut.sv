// § delayLiteralValueText152
`timescale 1ns/1ps
module top(input logic a, output logic b, output logic c);
  assign #2.25 b = a;
  wire #0.75 cw = a;
  assign c = cw;
endmodule
