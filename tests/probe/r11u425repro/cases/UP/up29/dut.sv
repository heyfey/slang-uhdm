// § unszPkgFoldElabForm425
// 'd200 read nda16 (grid g2/h05)
package p;
  parameter H = 'd200;
endpackage
module top(output logic [15:0] y); import p::*; wire [15:0] w = H; assign y = w; endmodule
