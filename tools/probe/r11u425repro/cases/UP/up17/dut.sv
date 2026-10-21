// § unszPkgFoldElabForm425 (control: 'b101 read ou, no § 425 law fires)
// 'b101 read ou (grid g1/g17)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = x + H;
endmodule
