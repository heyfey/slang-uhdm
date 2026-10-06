// § pkgSelIdxRefColons254 (the index a package function call, a package parameter, a ternary and a nested qualified select)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = {8'h1, 8'h2, 8'h3, 8'h4, 8'h5, 8'h6, 8'h7, 8'h8};
  parameter int IDX = 1;
  function automatic int f(int x); return x - 1; endfunction
endpackage
module top #(parameter int W = 2) (output logic [7:0] o, output logic [7:0] p, output logic [7:0] q, output logic [7:0] r);
  assign o = cp::R3[cp::f(W)][0];
  assign p = cp::R3[cp::IDX][W-1];
  assign q = cp::R3[W > 1 ? 1 : 0][W];
  assign r = cp::R3[cp::RC[0][W-2]][1];
endmodule
