// § caAnySysCallLhsTs428
module m(input [7:0] x, output [3:0] y);
  wire [3:0] t;
  assign t = $countones(x);
  assign y = t;
endmodule
module top(input [7:0] a, output [3:0] c);
  m u1(.x(a), .y(c));
endmodule
