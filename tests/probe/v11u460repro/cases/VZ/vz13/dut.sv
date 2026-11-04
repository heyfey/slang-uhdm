// § modArrPatBasedLitElemW460 (one-bit and wide elements)
module top;
  bit b1[2] = '{'h1, 'h0};
  logic [127:0] w[2] = '{'h1, 128'h2};
endmodule
