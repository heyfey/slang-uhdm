// § implicitPortParamListedFirst419
module m #(parameter A, parameter B=1) (input [A-1:0] x);
endmodule
module top;
  logic [3:0] x;
  m #(4) u(x);
endmodule
