// § elabCaBaseSelRefIdxAtElem290
module top(output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
assign o = ~st[1].a;
endmodule
