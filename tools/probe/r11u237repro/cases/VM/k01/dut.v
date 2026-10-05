// § vlogAggMemberKwSpan237
// v11u235's k11: an enum member beside a logic member
module top(output [3:0] o);
  typedef struct packed { enum bit [1:0] {A, B} f; logic [1:0] g; } s_t;
  s_t x;
  assign o = {x.f, x.g};
endmodule
