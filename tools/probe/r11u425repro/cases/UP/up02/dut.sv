// § unszPkgFoldElabForm425
// 'd200 read cq (grid g1/g02)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = p::H;
endmodule
