// § vlogAggMemberKwSpan237
// a struct member written through a macro whose body carries the type, the use on a second line
`define MT(w) logic [w-1:0]
module top(output [3:0] o);
  typedef struct packed {
    `MT(2) g;
    bit
      [1:0] h; } s_t;
  s_t x;
  assign o = x;
endmodule
