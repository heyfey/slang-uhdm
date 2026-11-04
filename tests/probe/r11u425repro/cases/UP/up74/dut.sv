// § unszPkgFoldElabForm425
// 'd0 read procop (grid g2/h50)
package p;
  parameter H = 'd0;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = x + p::H; endmodule
