// § unszPkgFoldNdaNoTs425
// 'b101 read ndaint (grid g2/h43)
package p;
  parameter H = 'b101;
endpackage
module top(output int y); import p::*; wire integer w = H; assign y = w; endmodule
