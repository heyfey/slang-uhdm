// § genCaPsBoundOpChain254 (indexed part-selects: an operation base, an operation width, a direct base, ascending and descending)
module top #(parameter int W = 4) (input logic [15:0] a, output logic [3:0] o [2], output logic [3:0] p [2], output logic [3:0] r [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = a[W-1 +: 4];
    assign p[k] = a[W+3 -: 4];
    assign r[k] = a[W +: 4];
  end
endmodule
