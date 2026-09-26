// § rangeQueryFoldUnconverted164 — $right of an unpacked array variable onto an implicit net
module top();
  logic [7:0] m [2:5];
  assign r = $right(m);
endmodule
