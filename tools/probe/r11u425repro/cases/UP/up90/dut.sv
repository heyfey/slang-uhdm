// § unszPkgFoldElabForm425 (control: 'd3000000000 read nda4, no § 425 law fires)
// 'd3000000000 read nda4 (grid g2/h66)
package p;
  parameter H = 'd3000000000;
endpackage
module top(output logic [3:0] y); import p::*; wire [3:0] w = H; assign y = w; endmodule
