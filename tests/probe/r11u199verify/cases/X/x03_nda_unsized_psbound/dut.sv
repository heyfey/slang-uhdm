// § ndaPsBoundOwner192 § caUnsizedRhsClonePerInst193 § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 3;
endpackage
module m import p::*; (input logic c, input logic [7:0] x, output logic [7:0] y [2], output logic [7:0] z);
  wire [7:0] n = c ? x[W:0] : '1;
  assign y[0][W:0] = c ? x[W:0] : '0;
  assign y[1] = n;
  assign z[7:W+1] = c ? x : '1;
  assign z[W:0] = n[W:0];
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a [2], output logic [7:0] b [2], output logic [7:0] d, output logic [7:0] e);
  m u_a (.c(c), .x(x), .y(a), .z(d));
  m u_b (.c(c), .x(x), .y(b), .z(e));
endmodule
