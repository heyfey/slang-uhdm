// § ppMacroBodyLines160
`define M(T, N) \
  T unused_fcov_``N; \
  assign unused_fcov_``N = fcov_``N;
module top (input logic fcov_wb_valid, input logic fcov_x);
  `M(logic, wb_valid)
  `M(logic, x)
endmodule
