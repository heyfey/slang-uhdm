// § caWholeSysCallSharesDefCell428
module m(input [7:0] x, output [3:0] y);
  assign y = $countones(x);
endmodule
module top(input [7:0] a, output [3:0] c);
  m u1(.x(a), .y(c));
endmodule
