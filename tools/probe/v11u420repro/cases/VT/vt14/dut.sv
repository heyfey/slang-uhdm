// § unpackedStructVarPosInit420
module top(input logic clk, output int y);
  struct { int a; int b; } s = '{1, 2};
  always_ff @(posedge clk) s.a <= s.a + 1;
  assign y = s.a;
endmodule
