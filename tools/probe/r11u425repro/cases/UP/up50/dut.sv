// § unszPkgFoldElabForm425 (control: 'h1F read procop, no § 425 law fires)
// 'h1F read procop (grid g2/h26)
package p;
  parameter H = 'h1F;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = x + p::H; endmodule
