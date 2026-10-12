// § elabCaBaseSelRefIdxAtElem290
module sub(input logic [1:0] p, output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
assign o = ~st[p].b;
endmodule
module top(input logic [1:0] p, output logic o1, o2);
sub u1(.p(p), .o(o1));
sub u2(.p(p), .o(o2));
endmodule
