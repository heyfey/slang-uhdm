// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; assign imp = 1'b1; always_comb a.v[ix[imp + 1] +: 2] = 0; endmodule
