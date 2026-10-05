// § genLpSysCallArgName239
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  localparam int M = N * 2;
  if (N == 1) begin : gen_deg
    assign o = r[0];
  end else begin : gen_normal_case
    localparam int unsigned NumLevels = $clog2(N) + 1;
    logic [NumLevels:0] t;
    assign t = '0;
    assign o = ^r ^ t[0];
  end
endmodule
