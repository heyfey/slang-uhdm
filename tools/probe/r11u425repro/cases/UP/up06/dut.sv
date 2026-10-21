// § unszPkgFoldElabForm425
// 'd200 read oq (grid g1/g06)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  assign y = x + p::H;
endmodule
