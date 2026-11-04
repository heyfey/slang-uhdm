// § sizeReachFollowsWalker219v § ndaSizeFoldReach219 — one argument on packed two-dimensional bit and logic variables and a logic net
module dut (output logic [7:0] o1, o2, o3);
  bit   [3:0][1:0] bp;
  logic [5:0][2:0] lp;
  wire  [6:0][1:0] np;
  wire [7:0] w1 = $size(bp);
  wire [7:0] w2 = $size(lp);
  wire [7:0] w3 = $size(np);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
