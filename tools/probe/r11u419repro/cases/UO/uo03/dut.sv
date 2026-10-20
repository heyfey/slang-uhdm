// § implicitPortParamListedFirst419
module m #(parameter A = 1, parameter B, parameter C = 3) (input [B-1:0] x);
  localparam L = A + B;
endmodule
module top;
  logic [3:0] x;
  m #(.B(4)) u(x);
endmodule
