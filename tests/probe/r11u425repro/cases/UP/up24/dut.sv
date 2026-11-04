// § unszPkgFoldElabForm425
// 'o17 read oq (grid g1/g24)
package p;
  parameter H = 'o17;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = x + p::H;
endmodule
