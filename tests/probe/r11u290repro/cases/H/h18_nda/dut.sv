// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
wire w = ~st[p].a;
assign o = w;
endmodule
