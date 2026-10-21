// § unszPkgFoldNdaNoTs425
// 'h1F read gen (grid g2/h32)
package p;
  parameter H = 'h1F;
endpackage
module top(output logic [7:0] y); import p::*; if (1) begin : g wire [7:0] w = H; assign y = w; end endmodule
