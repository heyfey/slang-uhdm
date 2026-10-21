// § unszPkgFoldElabForm425 (control: 'd3000000000 read func, no § 425 law fires)
// 'd3000000000 read func (grid g2/h64)
package p;
  parameter H = 'd3000000000;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); function automatic logic [7:0] f(); return p::H; endfunction assign y = f(); endmodule
