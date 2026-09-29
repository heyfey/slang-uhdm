// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v § unsizedInnerSizeDeclines223 — $size in net initializers of arrays whose FIRST dimension is dynamic or a queue (fixed inner), d = 2
module top(output logic [7:0] o1, output logic [7:0] o2);
  int da [][4];
  byte qa [$][2];
  wire [7:0] w1 = $size(da, 2);
  wire [7:0] w2 = $size(qa, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
