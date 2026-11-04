// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; logic [3:0] k; } a_t;
module top; a_t a; logic [1:0] o; always_comb o = a.v[a.k + 1 +: 2]; endmodule
