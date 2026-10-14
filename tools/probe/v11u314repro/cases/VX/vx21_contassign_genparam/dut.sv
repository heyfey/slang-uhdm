// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top #(parameter int W = 2); a_t a; int k; logic [1:0] o; if (W > 1) begin : g assign o = a.v[k + W - 2 +: 2]; end endmodule
