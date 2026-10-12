// § elabCaBaseSelRefIdxAtElem290
module top #(parameter int K = 1)(output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
assign o = ~st[K].a;
endmodule
