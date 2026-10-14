// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a [2]; int ix[4]; int k; for (genvar g = 0; g < 2; g++) begin : gf always_comb a[g].v[ix[k + g] +: 2] = 0; end endmodule
