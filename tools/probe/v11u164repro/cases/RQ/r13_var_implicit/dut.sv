// § rangeQueryFoldUnconverted164 — $high = 6 of a variable onto an implicit net
module top ();
  logic [6:3] a;
  assign ccc = $high(a);
endmodule
