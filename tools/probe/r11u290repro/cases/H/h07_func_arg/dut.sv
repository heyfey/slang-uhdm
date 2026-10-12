// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, input logic c, output logic [2:0] o);
typedef struct packed { logic [1:0] w; logic [1:0] a; } s_t;
s_t st [4];
function automatic logic [2:0] f(logic [1:0] x); return {1'b0, x}; endfunction
assign o = c ? f(st[p].a) : 3'd0;
endmodule
