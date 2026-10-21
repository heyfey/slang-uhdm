// § unszPkgFoldElabForm425
// 'o17 read caseitem (grid g2/h24)
package p;
  parameter H = 'o17;
endpackage
module top(input logic [7:0] x, output logic y); always_comb case (x) p::H: y = 1; default: y = 0; endcase endmodule
