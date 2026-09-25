// § rangeQueryFoldUnconverted164 — $right of an ascending negative range
module top ();
  logic [0:-5] a;
  assign ccc = $right(a);
endmodule
