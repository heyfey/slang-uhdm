// § psBoundPaOwnerName192
package p;
  parameter int unsigned L = 4;
  parameter int unsigned S = $clog2(16);
  parameter int unsigned O = 16/4;
endpackage
module top import p::*; #(parameter int PP = 4) (input logic [31:0] x, output logic [31:0] y1, y2, y3, y4, y5, y6, y7, y8);
  localparam int ML = 4;
  localparam int MS = $clog2(16);
  assign y1 = x[L:0];
  assign y2 = x[S:0];
  assign y3 = x[O:0];
  assign y4 = x[ML:0];
  assign y5 = x[MS:0];
  assign y6 = x[PP:0];
  assign y7 = x[S+1:S];
  assign y8 = x[p::S:0];
endmodule
