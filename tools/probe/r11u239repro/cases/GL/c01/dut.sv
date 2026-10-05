// § genLpSysCallArgName239
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic [7:0] o);
  if (N > 1) begin : g
    assign o = $clog2(N);
  end
endmodule
