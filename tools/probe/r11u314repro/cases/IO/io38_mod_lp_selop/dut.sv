// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; localparam int LP = 1; a_t a; int ix[4]; int k; always_comb a.v[ix[k + LP] +: 2] = 0; endmodule
