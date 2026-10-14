// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
module top #(parameter int S = 1); a_t a; int ix[4]; int k; case (S) 1: begin : gc always_comb a.v[ix[k + 1] +: 2] = 0; end default: ; endcase endmodule
