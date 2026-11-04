// § genLpSysCallArgName239
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  localparam int L = $clog2(N);
  assign o = r[0] ^ (L > 1);
endmodule
