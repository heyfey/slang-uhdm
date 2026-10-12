// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, input logic c, input logic [7:0] d, output logic [7:0] o);
typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
s_t st [4];
assign o = c ? st[p].a : d;
endmodule
