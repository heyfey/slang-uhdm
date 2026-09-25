// § tpDefaultCaLhsUnparented146
module inner #(parameter int N = 16, parameter type idx_t = logic [$clog2(N)-1:0])
  (input idx_t i, output idx_t o);
  assign o = i;
endmodule
module top(input [3:0] a, output [3:0] b);
  inner u(.i(a), .o(b));
endmodule
