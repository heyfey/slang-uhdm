// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a [2]; for (genvar g = 0; g < 2; g++) begin : gf always_comb a[g].v[g * 2 +: 2] = 0; end endmodule
