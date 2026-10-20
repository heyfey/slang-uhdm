// § implicitPortParamListedFirst419
module m #(parameter A = 1, int B = 2) (input [A-1:0] x, output [7:0] y);
  parameter P = 3;
  assign y = A + B + P;
endmodule
module top(input x, output [7:0] y1, y2);
  m #(.B(5)) u(x, y1);
  m #(1, 9) v(x, y2);
endmodule
