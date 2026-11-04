// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; logic [1:0] o; assign imp = 1; always_comb o = a.v[imp + 1 +: 2]; endmodule
