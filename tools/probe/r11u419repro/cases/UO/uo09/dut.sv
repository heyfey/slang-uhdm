// § implicitPortParamListedFirst419
module m #(parameter A, parameter B = 2, int C = 1) (input [A-1:0] x);
endmodule
module top;
  logic [3:0] x;
  m #(.A(4)) u(x);
endmodule
