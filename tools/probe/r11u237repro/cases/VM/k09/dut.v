// § vlogAggMemberKwSpan237
// keyword and dimension on two lines, odd spacing
module top(output [3:0] o);
  typedef struct packed {
    logic
      [1:0] a;
    bit   [1:0]   b;
  } s_t;
  s_t x;
  assign o = x;
endmodule
