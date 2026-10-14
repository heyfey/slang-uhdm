// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; int k; logic [1:0] o; assign o = a.v[ix[k + 1] +: 2]; endmodule
