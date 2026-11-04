// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; int k; logic [1:0] o; if (1) begin : g always_comb o = a.v[ix[k] +: 2]; end endmodule
