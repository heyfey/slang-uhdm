// § unszPkgFoldElabForm425
// 'd200 read nu (grid g1/g03)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = H; assign y = w;
endmodule
