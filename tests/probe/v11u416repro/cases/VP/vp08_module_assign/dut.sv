// § pasteBlankLedStartWritten416
`define ma(n) \
  assign w_``n = x & y;

module top(input logic x, y);
  logic w_a, w_bb, w_ccc, w_dddd;
  `ma(a)
  `ma(bb)
  `ma(ccc)
  `ma(dddd)
endmodule
