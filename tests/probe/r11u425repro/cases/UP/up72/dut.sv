// § unszPkgFoldElabForm425 (control: 'b101 read caseitem, no § 425 law fires)
// 'b101 read caseitem (grid g2/h48)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic y); always_comb case (x) p::H: y = 1; default: y = 0; endcase endmodule
