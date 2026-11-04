// § genLpSysCallArgName239
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_f
    localparam int unsigned L = $clog2(N + i);
    assign o[i] = r[0] ^ (L > 1);
  end
endmodule
