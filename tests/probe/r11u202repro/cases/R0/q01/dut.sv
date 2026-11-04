// § posOpConnKeepsRefModule200
module sub(input [3:0] a, input [3:0] b, output [3:0] o);
  assign o = a ^ b;
endmodule
module q01(input [3:0] x, input [3:0] y, output [3:0] o1, output [3:0] o2, output [3:0] o3);
  sub u1(x & y, y, o1);
  sub u2(~x, y, o2);
  sub u3(x, y | 4'h1, o3);
endmodule
