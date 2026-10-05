// § vlogAggMemberKwSpan237
// control: reg members
module top(output [3:0] o);
  typedef struct packed { reg [1:0] a; reg [1:0] b; } s_t;
  s_t x;
  assign o = x;
endmodule
