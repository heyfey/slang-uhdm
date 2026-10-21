// § unszPkgFoldElabForm425 (control: 'b101 read procop, no § 425 law fires)
// 'b101 read procop (grid g2/h38)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic [7:0] y); always_comb y = x + p::H; endmodule
