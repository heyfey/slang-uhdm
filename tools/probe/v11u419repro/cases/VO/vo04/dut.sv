// § implicitPortParamListedFirst419
module m #(parameter int A = 1, B = 2, logic [3:0] C = 4) (input [A-1:0] x, output [3:0] y);
  assign y = C + B;
endmodule
module top(input x, output [3:0] y);
  m #(.C(7)) u(x, y);
endmodule
