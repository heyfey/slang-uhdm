// § implicitPortParamListedFirst419
module m #(parameter A = 1, int B = 2) (input [A-1:0] x);
endmodule
module top;
  logic [0:0] x;
  m u(x);
endmodule
