// § unszPkgFoldElabForm425 (control: 'd200 read cu, no § 425 law fires)
// 'd200 read cu (grid g1/g01)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = H;
endmodule
