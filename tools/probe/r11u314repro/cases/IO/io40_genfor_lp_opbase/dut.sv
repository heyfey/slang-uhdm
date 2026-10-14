// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; localparam int LP = 6; a_t a [2]; for (genvar i = 0; i < 2; i++) begin : g always_comb a[i].v[LP - 1 -: 2] = 0; end endmodule
