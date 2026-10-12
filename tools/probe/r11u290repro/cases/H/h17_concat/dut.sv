// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, output logic [1:0] o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
assign o = {st[p].a, st[p].b};
endmodule
