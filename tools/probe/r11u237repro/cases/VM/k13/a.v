// § vlogAggMemberKwSpan237
// two .v files, the same declarator positions
module a(output [3:0] o);
  typedef struct packed { logic [1:0] p; bit [1:0] q; } s_t;
  s_t x;
  assign o = x;
endmodule
