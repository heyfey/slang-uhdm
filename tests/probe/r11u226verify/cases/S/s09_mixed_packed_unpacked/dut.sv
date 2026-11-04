// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of bit and byte arrays with packed and unpacked dimensions (bit is walked, byte is not)
module top(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  bit [2:0][1:0] bm [4];
  byte by [3][2];
  wire [7:0] w0 = $size(bm, 2);
  wire [7:0] w1 = $size(bm, 3);
  wire [7:0] w2 = $size(by, 2);
  wire [7:0] w3 = $size(by, 3);
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
