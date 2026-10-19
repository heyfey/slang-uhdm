// § genLpUntypedDefNoTs410
module m #(parameter W = 8);
  localparam L = $clog2(W);
  localparam K = W + 1;
  logic [L-1:0] x;
endmodule
module top;
  m u();
endmodule
