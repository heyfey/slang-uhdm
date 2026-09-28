// § psBoundPaOwnerName192 § caUnsizedRhsClonePerInst193 § ucCloneUnnamesRanges193v
package p;
  parameter int unsigned W = 3;
endpackage
module m import p::*; (input logic c, input logic [7:0] x, output logic [7:0] y);
  assign y[W:0] = c ? x[3:0] : '1;
  assign y[7:W+1] = x[7:4];
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a, output logic [7:0] b);
  m u_a (.c(c), .x(x), .y(a));
  m u_b (.c(c), .x(x), .y(b));
endmodule
