// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int k; always_comb begin : b a.v[$clog2(k) +: 2] = 0; end endmodule
