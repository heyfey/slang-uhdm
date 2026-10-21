// § unszBinNdaKeepsTickText425 (with § unszPkgFoldNdaNoTs425)
// 'b101 read gen (grid g2/h44)
package p;
  parameter H = 'b101;
endpackage
module top(output logic [7:0] y); import p::*; if (1) begin : g wire [7:0] w = H; assign y = w; end endmodule
