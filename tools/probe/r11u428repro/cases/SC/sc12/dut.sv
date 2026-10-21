// § caWholeSysCallSharesDefCell428
module m(input [3:0] x, output [2:0] y);
  wire [2:0] c = $countones(x);
  assign y = c;
endmodule
module top(input [3:0] a, output [2:0] b);
  m u1(a, b);
  m u2(a, );
endmodule
