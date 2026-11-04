// § procPsBoundOwner192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic clk, input logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
  always_ff @(posedge clk) y[W:0] <= x[W:0];
  initial z[31:W] = x[31:W];
endmodule
