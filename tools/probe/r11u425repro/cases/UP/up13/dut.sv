// § unszPkgFoldElabForm425 (control: 'b101 read cu, no § 425 law fires)
// 'b101 read cu (grid g1/g13)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = H;
endmodule
