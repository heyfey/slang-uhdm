// § elabCaBaseSelRefIdxAtElem290
interface ifc(input logic [1:0] p);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
logic o;
assign o = ~st[p].a;
endinterface
module top(input logic [1:0] p);
ifc u(.p(p));
endmodule
