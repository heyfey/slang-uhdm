// § implicitPortParamListedFirst419
module m #(parameter A = 1, int B = 2) (input [A-1:0] x, output [7:0] y);
  assign y = A * B;
endmodule
module top(input x, output [7:0] y);
  m #(.A(1), .B(4)) u(x, y);
endmodule
