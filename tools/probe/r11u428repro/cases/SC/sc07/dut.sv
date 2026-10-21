// § caWholeSysCallSharesDefCell428
module m(input [3:0] x, output [2:0] y);
  assign y = $countones(x);
endmodule
module top(input [3:0] a, output [2:0] b);
  m u(a, b);
endmodule
