// § unszPkgFoldElabForm425 (control: 'b101 read cq, no § 425 law fires)
// 'b101 read cq (grid g1/g14)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = p::H;
endmodule
