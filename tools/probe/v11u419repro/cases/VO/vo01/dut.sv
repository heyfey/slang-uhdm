// § implicitPortParamListedFirst419
module m #(A = 1, parameter B = 2, int C = 3) (input [A-1:0] x);
endmodule
module top;
  logic x;
  m u(x);
endmodule
