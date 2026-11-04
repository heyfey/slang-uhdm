// § unszPkgFoldElabForm425 (with § unszPkgFoldNdaNoTs425)
// 'o17 read nu (grid g1/g21)
package p;
  parameter H = 'o17;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = H; assign y = w;
endmodule
