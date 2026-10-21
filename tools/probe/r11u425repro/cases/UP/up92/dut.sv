// § unszPkgFoldElabForm425 (control: 'd3000000000 read gen, no § 425 law fires)
// 'd3000000000 read gen (grid g2/h68)
package p;
  parameter H = 'd3000000000;
endpackage
module top(output logic [7:0] y); import p::*; if (1) begin : g wire [7:0] w = H; assign y = w; end endmodule
