// § unszPkgFoldElabForm425
// 'd200 read nda4 (grid g2/h06)
package p;
  parameter H = 'd200;
endpackage
module top(output logic [3:0] y); import p::*; wire [3:0] w = H; assign y = w; endmodule
