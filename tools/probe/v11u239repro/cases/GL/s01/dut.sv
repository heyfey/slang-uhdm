// § genLpSysCallArgName239
// a for-generate localparam, $clog2 of a generate-local localparam and of the genvar
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic [3:0] o);
  for (genvar i = 1; i < 4; i++) begin : gf
    localparam int K = i * 3;
    localparam int W = $clog2(K);
    localparam int V = $clog2(N);
    assign o[i] = r[0] ^ (W > V);
  end
  assign o[0] = r[0];
endmodule
