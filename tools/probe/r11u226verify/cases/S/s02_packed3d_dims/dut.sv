// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of a three-dimensional packed logic vector with ascending and descending ranges, d = 1 to 3
module top(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  logic [2:0][0:3][1:0] pv;
  wire [7:0] w0 = $size(pv);
  wire [7:0] w1 = $size(pv, 1);
  wire [7:0] w2 = $size(pv, 2);
  wire [7:0] w3 = $size(pv, 3);
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
