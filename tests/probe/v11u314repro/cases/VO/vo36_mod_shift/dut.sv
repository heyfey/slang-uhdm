// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int k; logic [1:0] o; always_comb o = a.v[k << 1 +: 2]; endmodule
