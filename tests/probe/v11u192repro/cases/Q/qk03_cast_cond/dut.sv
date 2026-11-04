// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = $clog2(16);
  parameter int unsigned T = 2;
endpackage
module top (input logic [31:0] x, input logic c, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4, output logic [31:0] y5);
  assign y1 = x[int'(p::S):0];
  assign y2 = x[(p::S)-1:0];
  assign y3 = x[p::S*p::T-1:p::T];
  assign y4 = x[(p::S > 2 ? p::S : p::T):0];
  assign y5 = x[p::S:p::T];
endmodule
