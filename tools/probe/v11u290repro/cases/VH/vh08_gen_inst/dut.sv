// § elabCaBaseSelRefIdxAtElem290
module sub(input logic [1:0] p, output logic o);
typedef struct packed { logic a; logic b; } s_t;
s_t st [4];
assign o = st[p].a | st[p].b;
endmodule
module top(input logic [1:0] p, output logic [1:0] o);
for (genvar i = 0; i < 2; i++) begin : g
  sub u(.p(p), .o(o[i]));
end
endmodule
