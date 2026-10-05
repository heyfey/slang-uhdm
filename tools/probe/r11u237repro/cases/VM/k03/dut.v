// § vlogAggMemberKwSpan237
// a packed union
module top(output [7:0] o);
  typedef union packed { logic [7:0] a; bit [7:0] b; } u_t;
  u_t x;
  assign o = x.a;
endmodule
