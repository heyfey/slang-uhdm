// § implicitPortParamListedFirst419
module m #(parameter A = 1, int B = 2, C = 3, parameter D = 4) (input [A-1:0] x, output [7:0] y);
  assign y = A + B + C + D;
endmodule
module top(input x, output [7:0] y);
  m #(.D(2)) u(x, y);
endmodule
