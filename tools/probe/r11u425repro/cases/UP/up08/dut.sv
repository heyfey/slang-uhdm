// § unszPkgFoldElabForm425 (control: 'h1F read cq, no § 425 law fires)
// 'h1F read cq (grid g1/g08)
package p;
  parameter H = 'h1F;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = p::H;
endmodule
