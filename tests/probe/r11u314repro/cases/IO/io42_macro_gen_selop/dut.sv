// § ipsBaseOpSysRender314
`define SB ix[k + LP]
typedef struct packed { logic [7:0] v; } a_t;
module top; localparam int LP = 1; a_t a; int ix[4]; int k; if (1) begin : g always_comb a.v[`SB +: 2] = 0; end endmodule
