// § unszPkgFoldElabForm425 (control: 'b101 read func, no § 425 law fires)
// 'b101 read func (grid g2/h40)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); function automatic logic [7:0] f(); return p::H; endfunction assign y = f(); endmodule
