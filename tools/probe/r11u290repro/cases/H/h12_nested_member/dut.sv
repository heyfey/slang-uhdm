// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, output logic o);
typedef struct packed { logic a; logic b; } i_t;
typedef struct packed { i_t i; logic c; } s_t;
s_t st [4];
assign o = ~st[p].i.a;
endmodule
