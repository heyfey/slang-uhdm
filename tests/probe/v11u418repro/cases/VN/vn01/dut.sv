// § unnamedGateTermDefName418
module sub (input [1:0] a, output y);
  xor (y, a[0], a[1]);
endmodule
module top (input [1:0] a, output y1, y2);
  sub u1 (a, y1);
  sub u2 (a, y2);
endmodule
