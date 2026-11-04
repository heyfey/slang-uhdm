// § unszBinNdaKeepsTickText425 (with § unszPkgFoldNdaNoTs425)
// 'b101 read nu (grid g1/g15)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = H; assign y = w;
endmodule
