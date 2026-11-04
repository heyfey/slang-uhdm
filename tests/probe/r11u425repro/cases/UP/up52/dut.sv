// § unszPkgFoldElabForm425 (control: 'h1F read func, no § 425 law fires)
// 'h1F read func (grid g2/h28)
package p;
  parameter H = 'h1F;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); function automatic logic [7:0] f(); return p::H; endfunction assign y = f(); endmodule
