// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v § ndaAdjSizeFoldSized223 — $size of a two-dimensional enum array: d = 1 and 2 walk, d = 3 falls into the enum base range
module top(output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3);
  typedef enum logic [4:0] {E0, E1, E2} e_t;
  e_t ea [2][3];
  wire [3:0] w1 = $size(ea, 1);
  wire [3:0] w2 = $size(ea, 2);
  wire [3:0] w3 = $size(ea, 3);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
