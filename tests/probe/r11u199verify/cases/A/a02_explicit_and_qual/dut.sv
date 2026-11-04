// § psBoundPaOwnerName192 § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = 4;
  parameter int unsigned T = 2;
endpackage
package q;
  parameter int unsigned U = 7;
endpackage
module sub (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  import p::S;
  import q::*;
  assign y1 = x[S:0];
  assign y2 = x[U:p::T];
  assign y3 = {x[p::T:0], x[S:0]};
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  sub u1 (.*);
endmodule
