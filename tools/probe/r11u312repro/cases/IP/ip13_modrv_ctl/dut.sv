// § lvIpsNameFollowsHpRender312
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; s_t b; logic [1:0] o; assign o = a.v[b.k +: 2]; endmodule
