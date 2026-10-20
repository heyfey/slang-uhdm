// § implicitPortParamListedFirst419
module m #(parameter A = 4, int B = 2, type T = logic) (input [A-1:0] x);
endmodule
module top;
  logic [3:0] x;
  m u(x);
endmodule
