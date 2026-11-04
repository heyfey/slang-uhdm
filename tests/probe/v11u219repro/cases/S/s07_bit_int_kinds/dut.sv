// § sizeReachFollowsWalker219v § ndaSizeFoldReach219 — the two-argument form on operands Surelog keeps as bit, int and byte variables
module dut (output logic [7:0] o1, o2, o3, o4);
  bit [7:0] bv;
  int       iv;
  byte      yv;
  bit       bm [2][3];
  wire [7:0] w1 = $size(bv, 1);
  wire [7:0] w2 = $size(iv, 1);
  wire [7:0] w3 = $size(yv, 1);
  wire [7:0] w4 = $size(bm, 2);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
