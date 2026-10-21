// § unszPkgFoldElabForm425 (control: 'd3000000000 read proc, no § 425 law fires)
// 'd3000000000 read proc (grid g2/h61)
package p;
  parameter H = 'd3000000000;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = p::H; endmodule
