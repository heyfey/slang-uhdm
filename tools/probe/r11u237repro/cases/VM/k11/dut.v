// § vlogAggMemberKwSpan237
// a .v root including a header that declares the struct (Verilog mode inherited)
`include "s.vh"
module top(output [3:0] o);
  s_t x;
  assign o = x;
endmodule
