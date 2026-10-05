// § vlogAggMemberKwSpan237
// a bit member sized by a parameter expression
module top #(parameter N = 4) (output [N:0] o);
  typedef struct packed { bit [N-1:0] g; logic h; } s_t;
  s_t x;
  assign o = x;
endmodule
