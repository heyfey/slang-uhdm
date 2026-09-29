// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of a three-dimensional unpacked array of a logic vector, the one-argument form and d = 1 to the rank plus the packed dimension
module top(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4);
  logic [5:0] m [2][3][4];
  wire [7:0] w0 = $size(m);
  wire [7:0] w1 = $size(m, 1);
  wire [7:0] w2 = $size(m, 2);
  wire [7:0] w3 = $size(m, 3);
  wire [7:0] w4 = $size(m, 4);
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
