// § implicitPortParamListedFirst419
module m #(parameter A = 1, type T = int, int B = 2) (input [A-1:0] x);
  T v;
endmodule
module top;
  logic x;
  m u(x);
endmodule
