// § bothEdgeIsAnyEdgeOp401
module top();
  reg a = 0;
  wire clk = 0, rst = 0;
  always @(edge clk or posedge rst) a <= ~a;
endmodule
