// § pkgSelIdxRefColons254 (the qualified select written through a macro, and its index from a macro)
package cp;
  parameter logic [1:0][3:0][7:0] R3 = '1;
endpackage
`define SEL(a, b) cp::R3[a][b]
`define IX W-1
module top #(parameter int W = 2) (output logic [7:0] o, output logic [7:0] p);
  assign o = `SEL(W-1, 0);
  assign p = cp::R3[`IX][0];
endmodule
