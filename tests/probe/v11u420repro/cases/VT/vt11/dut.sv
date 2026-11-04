// § unpackedStructVarPosInit420
module top(output int y);
  struct { int a; int b; } s = '{1, 2};
  assign y = s.a + s.b;
endmodule
