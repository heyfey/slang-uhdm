// § bothEdgeIsAnyEdgeOp401
module top;
  logic clk, en, q;
  always @(edge clk iff en) q <= ~q;
endmodule
