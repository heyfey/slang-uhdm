// § implicitPortParamListedFirst419
module m #(parameter int A, parameter int B = 1, parameter C = 5) (input [A-1:0] x);
endmodule
module top;
  logic [3:0] x;
  m #(.A(4)) u(x);
endmodule
