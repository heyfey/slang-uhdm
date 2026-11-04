// § unszBinNdaKeepsTickText425 (with § unszPkgFoldNdaNoTs425)
// 'b101 read nda4 (grid g2/h42)
package p;
  parameter H = 'b101;
endpackage
module top(output logic [3:0] y); import p::*; wire [3:0] w = H; assign y = w; endmodule
