// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
interface ifc; a_t a; int ix[4]; int k; always_comb begin : b a.v[ix[k + 1] +: 2] = 0; end endinterface
module top; ifc u(); endmodule
