// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of two-dimensional unpacked NETS (a wire array and a tri array), d = 1 to 3
module top(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  wire [3:0] wn [2][3];
  tri [0:5] tn [4];
  wire [7:0] w0 = $size(wn);
  wire [7:0] w1 = $size(wn, 2);
  wire [7:0] w2 = $size(wn, 3);
  wire [7:0] w3 = $size(tn, 2);
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
