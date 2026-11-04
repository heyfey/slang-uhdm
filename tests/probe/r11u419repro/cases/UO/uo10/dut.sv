// § implicitPortParamListedFirst419
module m #(parameter A = 4, B = 2, int C = 1, D = 3) (input [A-1:0] x);
endmodule
module top;
  logic [3:0] x;
  m u(x);
endmodule
