// § macroIfaceRangeSelBaseTok256 (a cross-module path to a child variable in the macro)
`define wr(P, LSB) \
  assign P.r[LSB+:2] = x;
module c; logic [7:0] r; endmodule
module m; logic [1:0] x; c ci();
  `wr(ci, 3)
endmodule
module top; m u(); endmodule
