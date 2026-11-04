// § pkgSelIdxRefColons254 (the index a parameter of another package, written qualified)
package cp;
  parameter logic [1:0][3:0][7:0] R3 = {8'h1, 8'h2, 8'h3, 8'h4, 8'h5, 8'h6, 8'h7, 8'h8};
  parameter int IDX = 1;
  function automatic int f(int x); return x - 1; endfunction
endpackage
package q;
  parameter int IDX = 0;
endpackage
module top #(parameter int W = 2) (output logic [7:0] p);
  assign p = cp::R3[q::IDX][W-1];
endmodule
