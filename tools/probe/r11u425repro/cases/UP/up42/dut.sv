// § unszPkgFoldElabForm425 (with § unszPkgFoldNdaNoTs425)
// 'o17 read nda4 (grid g2/h18)
package p;
  parameter H = 'o17;
endpackage
module top(output logic [3:0] y); import p::*; wire [3:0] w = H; assign y = w; endmodule
