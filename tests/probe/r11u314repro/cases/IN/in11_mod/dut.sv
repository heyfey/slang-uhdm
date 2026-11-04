// § ipsBaseInnerNamesFollowRender314
typedef struct packed { logic [7:0] v; } a_t;
typedef struct packed { logic [3:0] k; } b_t;
module top; a_t a; b_t b; always_comb a.v[b.k +: 2] = 0; endmodule
