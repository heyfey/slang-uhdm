// § rangeQueryFoldUnconverted164 — $low onto an implicit net (value 1: control)
module top ();
  parameter [2:1] a = 10;
  assign ccc = $low(a);
endmodule
