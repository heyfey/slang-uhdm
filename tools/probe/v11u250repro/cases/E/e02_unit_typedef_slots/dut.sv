// § modParamKwTdCopy250
// $unit keyword typedefs typing module parameters used in a port dimension, a part-select bound, an indexed width, a replication count and a for-generate bound
typedef int i_t;
typedef logic l_t;
typedef integer g_t;
typedef byte unsigned bu_t;
module top #(parameter i_t W = 8, parameter g_t N = 2, parameter bu_t K = 3, parameter l_t E = 1'b1)
  (input logic [W-1:0] i, output logic [W-1:0] o, output logic [7:0] r);
  localparam i_t H = W / 2;
  assign o = {i[H-1:0], i[W-1 -: H]};
  assign r = {N{i[K +: 4]}};
  for (genvar g = 0; g < N; g++) begin : gb
    if (E) begin : e
      logic t;
      assign t = i[g];
    end
  end
endmodule
