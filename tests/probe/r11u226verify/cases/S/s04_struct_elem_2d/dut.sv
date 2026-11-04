// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size of a two-dimensional unpacked array of a packed struct and of an unpacked struct, d = 1 and 2
module top(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  typedef struct packed { logic [3:0] a; logic b; } ps_t;
  typedef struct { int x; logic y; } us_t;
  ps_t pa [2][6];
  us_t ua [4][2];
  wire [7:0] w0 = $size(pa, 1);
  wire [7:0] w1 = $size(pa, 2);
  wire [7:0] w2 = $size(ua);
  wire [7:0] w3 = $size(ua, 2);
  assign o0 = w0; assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
