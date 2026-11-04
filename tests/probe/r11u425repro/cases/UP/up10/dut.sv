// § unszPkgFoldElabForm425 (control: 'h1F read nq, no § 425 law fires)
// 'h1F read nq (grid g1/g10)
package p;
  parameter H = 'h1F;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = p::H; assign y = w;
endmodule
