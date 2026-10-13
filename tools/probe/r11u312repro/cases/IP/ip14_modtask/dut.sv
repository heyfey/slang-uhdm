// § lvIpsNameFollowsHpRender312
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; s_t b; task t(); a.v[b.k +: 2] = 2'b0; endtask initial t(); endmodule
