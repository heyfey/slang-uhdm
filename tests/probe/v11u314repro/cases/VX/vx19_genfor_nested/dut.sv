// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; for (genvar g = 0; g < 2; g++) begin : g1 for (genvar h = 0; h < 2; h++) begin : g2 logic [1:0] o; always_comb o = a.v[ix[g + h] +: 2]; end end endmodule
