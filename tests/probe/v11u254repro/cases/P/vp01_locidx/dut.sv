// § pkgSelIdxRefColons254 (the index a local variable, a genvar and a module localparam beside a header parameter)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = {8'h1, 8'h2, 8'h3, 8'h4, 8'h5, 8'h6, 8'h7, 8'h8};
  parameter int IDX = 1;
  function automatic int f(int x); return x - 1; endfunction
endpackage
module top #(parameter int W = 2) (input logic [1:0] i, output logic [7:0] o, output logic [7:0] p [2], output logic [7:0] q);
  localparam int L = 1;
  always_comb o = cp::R3[i][0];
  for (genvar k = 0; k < 2; k++) begin : gk
    assign p[k] = cp::R3[k][W-1];
  end
  assign q = cp::R3[L][W];
endmodule
