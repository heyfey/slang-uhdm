// § unszBinNdaKeepsTickText425 (with § unszPkgFoldNdaNoTs425)
// 'b101 read nda16 (grid g2/h41)
package p;
  parameter H = 'b101;
endpackage
module top(output logic [15:0] y); import p::*; wire [15:0] w = H; assign y = w; endmodule
