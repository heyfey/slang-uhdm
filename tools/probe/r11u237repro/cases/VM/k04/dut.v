// § vlogAggMemberKwSpan237
// control: scalar members (no packed dimension)
module top(output [1:0] o);
  typedef struct packed { logic a; bit b; } s_t;
  s_t x;
  assign o = x;
endmodule
