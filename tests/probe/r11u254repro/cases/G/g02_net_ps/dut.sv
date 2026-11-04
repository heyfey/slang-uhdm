// § genCaPsBoundOpChain254 (a module net's part-select with operation bounds, the lower bound and both, in for and if generate scopes)
module top #(parameter int W = 4, parameter int P = 1) (input logic [7:0] a, output logic [3:0] o [2], output logic [3:0] q);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = a[W-1:0];
  end
  if (P == 1) begin : gi
    assign q = a[W+3:W];
  end
endmodule
