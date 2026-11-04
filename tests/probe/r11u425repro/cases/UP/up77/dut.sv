// § unszPkgFoldElabForm425
// 'd0 read nda16 (grid g2/h53)
package p;
  parameter H = 'd0;
endpackage
module top(output logic [15:0] y); import p::*; wire [15:0] w = H; assign y = w; endmodule
