// § unszPkgFoldElabForm425 (control: 'd3000000000 read procop, no § 425 law fires)
// 'd3000000000 read procop (grid g2/h62)
package p;
  parameter H = 'd3000000000;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = x + p::H; endmodule
