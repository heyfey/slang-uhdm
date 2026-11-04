// § ipsBaseOpSysRender314
`define SB ix[k + 1]
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; int k; always_comb a.v[`SB +: 2] = 0; endmodule
