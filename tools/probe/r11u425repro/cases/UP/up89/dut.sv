// § unszPkgFoldElabForm425 (control: 'd3000000000 read nda16, no § 425 law fires)
// 'd3000000000 read nda16 (grid g2/h65)
package p;
  parameter H = 'd3000000000;
endpackage
module top(output logic [15:0] y); import p::*; wire [15:0] w = H; assign y = w; endmodule
