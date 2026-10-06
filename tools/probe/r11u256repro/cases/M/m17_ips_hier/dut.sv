// § macroIfaceRangeSelBaseTok256 (a hierarchical (cross-module) path in a macro body)
`define conn(P, LSB) \
  assign  P.r[LSB+:4] = x;
module sub; logic [7:0] r; endmodule
module top; logic [3:0] x; sub s();
  `conn(s, 4)
endmodule
