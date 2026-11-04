// § unszPkgFoldElabForm425 (with § unszPkgFoldNdaNoTs425)
// 'o17 read gen (grid g2/h20)
package p;
  parameter H = 'o17;
endpackage
module top(output logic [7:0] y); import p::*; if (1) begin : g wire [7:0] w = H; assign y = w; end endmodule
