// § unszPkgFoldElabForm425
// 'd200 read proc (grid g2/h01)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = p::H; endmodule
