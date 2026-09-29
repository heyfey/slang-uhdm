// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v § ndaAdjSizeFoldSized223 — in one module: a $size the reach folds (walker resolves), one the walker declines (the adjuster folds in the elaborated view), and one of a leading-fixed associative array
module top(output logic [3:0] o1, output logic [3:0] o2, output logic [5:0] o3);
  typedef enum logic [2:0] {A, B, C} e_t;
  logic [1:0] m [3][5];
  e_t ea [2][3];
  int ma [4][int];
  wire [3:0] w1 = $size(m, 2);
  wire [3:0] w2 = $size(ea, 3);
  wire [5:0] w3 = $size(ma);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
