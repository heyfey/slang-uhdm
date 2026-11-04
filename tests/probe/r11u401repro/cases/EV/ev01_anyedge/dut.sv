// § bothEdgeIsAnyEdgeOp401
module top();
  reg [3:0] a = 0;
  wire clk = 0;
  always @(edge clk) a = ~a;
endmodule
