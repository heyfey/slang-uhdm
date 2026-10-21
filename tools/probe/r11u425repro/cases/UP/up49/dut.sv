// § unszPkgFoldElabForm425 (control: 'h1F read proc, no § 425 law fires)
// 'h1F read proc (grid g2/h25)
package p;
  parameter H = 'h1F;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = p::H; endmodule
