// § posOpConnKeepsRefModule200
module sub(input [3:0] a, input b, output [3:0] o);
  assign o = b ? a : 4'h0;
endmodule
module q03(input [3:0] x, input s, output [3:0] o1);
  sub u1(s ? x : ~x, s, o1);
endmodule
