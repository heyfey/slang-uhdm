// § vlogAggMemberKwSpan237
// a nested anonymous struct member and a union member in Verilog mode
module top(output [5:0] o);
  typedef struct packed { struct packed { logic [1:0] a; bit [1:0] b; } n; logic [1:0] g; } s_t;
  s_t x;
  assign o = x;
endmodule
