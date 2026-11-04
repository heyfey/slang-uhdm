// § unszPkgFoldElabForm425
// 'd200 read procop (grid g2/h02)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = x + p::H; endmodule
