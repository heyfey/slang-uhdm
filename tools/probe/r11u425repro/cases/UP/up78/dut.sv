// § unszPkgFoldElabForm425
// 'd0 read nda4 (grid g2/h54)
package p;
  parameter H = 'd0;
endpackage
module top(output logic [3:0] y); import p::*; wire [3:0] w = H; assign y = w; endmodule
