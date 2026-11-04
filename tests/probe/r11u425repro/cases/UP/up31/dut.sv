// § unszPkgFoldElabForm425
// 'd200 read ndaint (grid g2/h07)
package p;
  parameter H = 'd200;
endpackage
module top(output int y); import p::*; wire integer w = H; assign y = w; endmodule
