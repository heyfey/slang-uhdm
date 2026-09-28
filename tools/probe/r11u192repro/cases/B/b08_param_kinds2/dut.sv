// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
  localparam int unsigned LS = 4;
  parameter U = 4;
  parameter logic [3:0] LG = 4'd4;
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y1, y2, y3, y4, y5, y6);
  localparam int MS = $clog2(16);
  assign y1 = x[MS:0];
  assign y2 = x[p::S:0];
  assign y3 = x[LS:0];
  assign y4 = x[U:0];
  assign y5 = x[LG:0];
  assign y6 = x[S:S-2];
endmodule
