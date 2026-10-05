// § vlogAggMemberKwSpan237
// two packed dimensions on a logic member
module top(output [7:0] o);
  typedef struct packed { logic [1:0][3:0] g; } s_t;
  s_t x;
  assign o = x;
endmodule
