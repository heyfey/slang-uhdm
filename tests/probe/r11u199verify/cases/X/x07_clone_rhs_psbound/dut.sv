// § psBoundPaOwnerName192 § caUnsizedRhsClonePerInst193
package p;
  parameter int unsigned W = 3;
endpackage
module m import p::*; (input logic c, input logic [7:0] x, output logic [7:0] y);
  assign y[3:0] = c ? x[W:0] : '0;
  assign y[7:4] = x[7:4];
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a, output logic [7:0] b);
  m u_a (.c(c), .x(x), .y(a));
  m u_b (.c(c), .x(x), .y(b));
endmodule
