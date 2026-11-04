// § unszPkgFoldElabForm425 (control: 'o17 read ou, no § 425 law fires)
// 'o17 read ou (grid g1/g23)
package p;
  parameter H = 'o17;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = x + H;
endmodule
