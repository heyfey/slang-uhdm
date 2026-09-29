// § sizeReachFollowsWalker219v § ndaSizeFoldReach219 — arrays of an enum and of a packed struct, one and two arguments, and a packed struct operand itself (the break: golden folds w1 through ExprEval's generic handler to 9, the law wrote 3; downstream IDENTICAL -> DIVERGENT)
module dut (output logic [7:0] o1, o2, o3, o4, o5);
  typedef enum logic [2:0] {E0, E1, E2} e_t;
  typedef struct packed { logic [4:0] a; logic b; } ps_t;
  e_t  ea [3];
  ps_t pa [4][2];
  ps_t ps;
  wire [7:0] w1 = $size(ea, 2);
  wire [7:0] w2 = $size(pa);
  wire [7:0] w3 = $size(pa, 2);
  wire [7:0] w4 = $size(pa, 3);
  wire [7:0] w5 = $size(ps, 1);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4; assign o5 = w5;
endmodule
