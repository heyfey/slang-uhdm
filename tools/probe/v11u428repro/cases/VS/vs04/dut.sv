// § caWholeSysCallSharesDefCell428
module m(input [7:0] x, output [3:0] y);
  assign y = $countones(x);
endmodule
module top(input [7:0] a, b, output [3:0] c, d);
  m u1(.x(a), .y(c));
  m u2(.x(b), .y(d));
endmodule
