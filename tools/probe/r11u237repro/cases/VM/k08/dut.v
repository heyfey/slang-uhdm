// § vlogAggMemberKwSpan237
// the struct written in a macro body
`define MKS(n) typedef struct packed { logic [1:0] a; bit [1:0] b; } n;
module top(output [3:0] o);
  `MKS(s_t)
  s_t x;
  assign o = x;
endmodule
