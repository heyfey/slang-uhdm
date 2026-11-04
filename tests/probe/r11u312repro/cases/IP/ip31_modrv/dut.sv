// § ipsBaseSelCallRender312
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; logic [3:0] ix [4]; int i; logic [1:0] o; assign o = a.v[ix[i] +: 2]; endmodule
