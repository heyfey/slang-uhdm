// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = 3;
  parameter int unsigned A [2] = '{4, 6};
  parameter int unsigned T = S + 1;
endpackage
package q;
  parameter int unsigned U = p::S + 2;
endpackage
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4, output logic [31:0] y5);
  assign y1 = x[q::U:0];
  assign y2 = x[p::A[1]:0];
  assign y3 = x[p::A[p::S-2]:p::S];
  assign y4 = x[((p::T)):0];
  assign y5 = x[p::T:q::U-p::S];
endmodule
