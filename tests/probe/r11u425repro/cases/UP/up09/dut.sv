// § unszPkgFoldNdaNoTs425
// 'h1F read nu (grid g1/g09)
package p;
  parameter H = 'h1F;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = H; assign y = w;
endmodule
