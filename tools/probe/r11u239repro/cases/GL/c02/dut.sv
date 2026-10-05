// § genLpSysCallArgName239
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  if (N > 1) begin : g
    logic [$clog2(N)-1:0] t;
    assign t = r[1:0];
    assign o = ^t;
  end
endmodule
