// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module c #(parameter int P = 1) (input int k, output logic [1:0] o); a_t a; always_comb o = a.v[k * P +: 2]; endmodule
module top; int k; logic [1:0] o; c #(.P(2)) u(.k(k), .o(o)); endmodule
