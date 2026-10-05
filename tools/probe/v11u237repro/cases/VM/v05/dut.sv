// § vlogAggMemberKwSpan237
// a .sv root including a .vh header that declares the struct (SystemVerilog mode inherited: control)
`include "s.vh"
module top(output [3:0] o);
  s_t x;
  assign o = x;
endmodule
