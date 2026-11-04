// § genLpSysCallArgName239
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  if (N > 1) begin : g
    localparam int L = N;
    localparam int K = $clog2(L);
    assign o = r[0] ^ (K > 1);
  end
endmodule
