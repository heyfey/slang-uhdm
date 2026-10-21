// § unszPkgFoldElabForm425
// 'o17 read procop (grid g2/h14)
package p;
  parameter H = 'o17;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = x + p::H; endmodule
