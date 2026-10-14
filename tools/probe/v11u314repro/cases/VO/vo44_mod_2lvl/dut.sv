// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } b_t;
typedef struct packed { b_t b; } a_t;
module top; a_t a; int k; logic [1:0] o; always_comb o = a.b.v[k - 1 +: 2]; endmodule
