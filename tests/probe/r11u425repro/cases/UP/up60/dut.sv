// § unszPkgFoldElabForm425 (control: 'h1F read caseitem, no § 425 law fires)
// 'h1F read caseitem (grid g2/h36)
package p;
  parameter H = 'h1F;
endpackage
module top(input logic [7:0] x, output logic y); always_comb case (x) p::H: y = 1; default: y = 0; endcase endmodule
