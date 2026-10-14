// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; logic [1:0] o [2]; for (genvar g = 0; g < 2; g++) begin : gf always_comb o[g] = a.v[ix[g + 1] +: 2]; end endmodule
