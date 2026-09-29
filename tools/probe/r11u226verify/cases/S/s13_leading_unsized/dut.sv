// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v § unsizedInnerSizeDeclines223 — $size in net initializers of arrays whose FIRST dimension is associative (fixed inner), with d = 1 and 2
module top(output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  int aa [int][3];
  logic [3:0] ab [byte][2];
  wire [7:0] w1 = $size(aa, 2);
  wire [7:0] w2 = $size(ab, 2);
  wire [7:0] w3 = $size(aa);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
