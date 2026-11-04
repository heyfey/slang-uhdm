// § genLpSysCallArgName239
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  typedef logic [7:0] b_t;
  if (N > 1) begin : g
    localparam int L = $bits(b_t);
    assign o = r[0] ^ (L > 1);
  end
endmodule
