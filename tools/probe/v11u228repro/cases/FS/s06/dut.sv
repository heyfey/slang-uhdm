// § parseViewSizeExprEval228 — wire logic, wire integer and a packed-struct net as targets
module dut (output logic [7:0] o1, output integer o2, output logic [7:0] o3);
  typedef struct packed { logic [7:0] a; } s_t;
  bit [5:0][1:0] bp;
  wire logic [7:0] w1 = $size(bp);
  wire integer w2 = $size(bp);
  wire s_t w3 = $size(bp);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
