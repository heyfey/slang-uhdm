// § ipsBaseOpSysRender314
typedef struct { logic [7:0] v; } u_t;
module top; u_t a; int k; logic [1:0] o; always_comb o = a.v[k + 1 +: 2]; endmodule
