// § unszPkgFoldNdaNoTs425
// 'h1F read nda4 (grid g2/h30)
package p;
  parameter H = 'h1F;
endpackage
module top(output logic [3:0] y); import p::*; wire [3:0] w = H; assign y = w; endmodule
