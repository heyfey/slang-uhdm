// § ipsBaseSelCallRender312
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; logic [3:0] ix [4]; int i; always_comb a.v[ix[i] +: 2] = 2'b0; endmodule
