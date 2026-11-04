// § unszPkgFoldElabForm425
// 'o17 read nq (grid g1/g22)
package p;
  parameter H = 'o17;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = p::H; assign y = w;
endmodule
