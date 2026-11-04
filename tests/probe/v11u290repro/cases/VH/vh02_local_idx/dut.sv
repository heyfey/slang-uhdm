// § elabCaBaseSelRefIdxAtElem290
module top(output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
logic [1:0] k;
assign o = st[k].a & st[k].b;
endmodule
