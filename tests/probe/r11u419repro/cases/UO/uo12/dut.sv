// § implicitPortParamListedFirst419
module m #(int A = 4, parameter B = 2) (input [A-1:0] x);
endmodule
module top;
  logic [3:0] x;
  m u(x);
endmodule
