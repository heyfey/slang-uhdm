// § unszPkgFoldElabForm425
// 'd0 read proc (grid g2/h49)
package p;
  parameter H = 'd0;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = p::H; endmodule
