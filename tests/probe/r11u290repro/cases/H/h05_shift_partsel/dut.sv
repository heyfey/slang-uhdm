// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, input logic c, output logic [31:0] o);
typedef struct packed { logic [31:0] w; logic [31:0] a; } s_t;
s_t st [4];
assign o = c ? 32'd0 : st[p].w << (8 * st[p].a[1:0]);
endmodule
