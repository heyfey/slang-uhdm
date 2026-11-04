// § implicitPortParamListedFirst419
module m #(parameter A, parameter B) (input [A-1:0] x);
endmodule
module top;
  logic [3:0] x;
  m #(.A(4), .B(2)) u(x);
endmodule
