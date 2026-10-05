// § vlogAggMemberKwSpan237
// a nested struct member and two dimensions
module top(output [7:0] o);
  typedef struct packed { logic [1:0][1:0] a; struct packed { bit [1:0] c; logic [1:0] d; } n; } s_t;
  s_t x;
  assign o = x;
endmodule
