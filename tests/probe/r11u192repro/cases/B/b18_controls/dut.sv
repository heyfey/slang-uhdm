// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; #(parameter int PP = 4) (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4, output logic [31:0] y5);
  localparam int ML = $clog2(16);
  assign y1 = x[ML:0];
  assign y2 = x[PP:0];
  assign y3 = x[S-1:0];
  assign y4 = {x[S-1:0], 1'b0};
  wire [31:0] w = x[S:0];
  assign y5 = w;
endmodule
