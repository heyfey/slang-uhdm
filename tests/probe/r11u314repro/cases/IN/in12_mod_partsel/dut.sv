// § ipsBaseInnerNamesFollowRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; logic [7:0] w; always_comb a.v[w[3:0] +: 2] = 0; endmodule
