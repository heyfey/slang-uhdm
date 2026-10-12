// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, input logic [1:0] q, output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4][4];
assign o = ~st[p][q].a;
endmodule
