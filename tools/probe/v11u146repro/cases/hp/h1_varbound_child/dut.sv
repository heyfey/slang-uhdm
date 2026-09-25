// § constPathBaseAnyKind146
module child(input logic [7:0] d, output logic [7:0] q);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  s_t s;
  logic [$bits(s.x)-1:0] w;
  assign s = d; assign w = s.x; assign q = {w, s.y};
endmodule
module top(input logic [7:0] d, output logic [7:0] q);
  logic [1:0] other;
  child c(.d(d), .q(q));
endmodule
