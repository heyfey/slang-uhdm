// § rangeQueryFoldUnconverted164 — $high of a negative range onto an implicit net
module top ();
  parameter [-1:-3] a = 0;
  assign ccc = $high(a);
endmodule
