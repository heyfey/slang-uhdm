// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, input logic i, output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
assign st[1].a = ~i;
assign o = st[p].a ^ i;
endmodule
