// § unszPkgFoldElabForm425 (control: 'o17 read cq, no § 425 law fires)
// 'o17 read cq (grid g1/g20)
package p;
  parameter H = 'o17;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = p::H;
endmodule
