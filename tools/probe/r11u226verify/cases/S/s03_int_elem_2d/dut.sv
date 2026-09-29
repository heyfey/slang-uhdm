// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of a two-dimensional unpacked int array, d = 1, 2 and 3 (past the unpacked rank into the int element)
module top(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  int ia [3][5];
  wire [7:0] w0 = $size(ia);
  wire [7:0] w1 = $size(ia, 1);
  wire [7:0] w2 = $size(ia, 2);
  wire [7:0] w3 = $size(ia, 3);
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
