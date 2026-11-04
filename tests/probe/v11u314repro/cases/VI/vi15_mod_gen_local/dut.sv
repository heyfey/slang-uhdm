// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; if (1) begin : g int k; always_comb a.v[ix[k + 1] +: 2] = 0; end endmodule
