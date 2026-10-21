// § unszPkgFoldElabForm425
// 'd0 read func (grid g2/h52)
package p;
  parameter H = 'd0;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); function automatic logic [7:0] f(); return p::H; endfunction assign y = f(); endmodule
