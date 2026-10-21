// § unszPkgFoldElabForm425
// 'd200 read func (grid g2/h04)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); function automatic logic [7:0] f(); return p::H; endfunction assign y = f(); endmodule
