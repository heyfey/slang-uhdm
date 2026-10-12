// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, output logic [1:0] o);
typedef struct packed { logic [31:0] w; logic [31:0] a; } s_t;
s_t st [4];
assign o = ~st[p].a[1:0];
endmodule
