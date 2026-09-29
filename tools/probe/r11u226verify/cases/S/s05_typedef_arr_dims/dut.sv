// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of an array whose element is a typedef'd unpacked array, and of a typedef'd packed array, d = 1 to 3
module top(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4);
  typedef logic [3:0] row_t [5];
  typedef logic [1:0][6:0] pk_t;
  row_t r2 [2];
  pk_t pk;
  wire [7:0] w0 = $size(r2);
  wire [7:0] w1 = $size(r2, 2);
  wire [7:0] w2 = $size(r2, 3);
  wire [7:0] w3 = $size(pk, 1);
  wire [7:0] w4 = $size(pk, 2);
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
