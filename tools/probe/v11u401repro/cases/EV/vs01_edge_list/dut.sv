// § bothEdgeIsAnyEdgeOp401
module top;
  logic clk, rst, q;
  always @(edge clk or posedge rst) q <= ~q;
  initial begin @(edge rst); q = 0; end
endmodule
