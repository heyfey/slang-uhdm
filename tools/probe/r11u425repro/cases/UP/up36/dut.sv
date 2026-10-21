// § unszPkgFoldElabForm425
// 'd200 read caseitem (grid g2/h12)
package p;
  parameter H = 'd200;
endpackage
module top(input logic [7:0] x, output logic y); always_comb case (x) p::H: y = 1; default: y = 0; endcase endmodule
