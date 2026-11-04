// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t [3:0] st;
assign o = ~st[p].a;
endmodule
