// § unszPkgFoldElabForm425
// 'd0 read gen (grid g2/h56)
package p;
  parameter H = 'd0;
endpackage
module top(output logic [7:0] y); import p::*; if (1) begin : g wire [7:0] w = H; assign y = w; end endmodule
