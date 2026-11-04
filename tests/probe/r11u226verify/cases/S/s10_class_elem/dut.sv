// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of an array of class handles and of strings, two-dimensional
module top(output logic [7:0] o0, output logic [7:0] o1);
  class c_t; int v; endclass
  c_t ca [3][2];
  string sa [2][5];
  wire [7:0] w0 = $size(ca, 2);
  wire [7:0] w1 = $size(sa);
  assign o0 = w0; assign o1 = w1;
endmodule
