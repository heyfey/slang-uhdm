// § unszPkgFoldNdaNoTs425
// 'h1F read nda16 (grid g2/h29)
package p;
  parameter H = 'h1F;
endpackage
module top(output logic [15:0] y); import p::*; wire [15:0] w = H; assign y = w; endmodule
