// § implicitPortParamListedFirst419
module m #(parameter A = 1, localparam L = 2, int B = 3) (input [A-1:0] x);
endmodule
module top;
  logic x;
  m u(x);
endmodule
