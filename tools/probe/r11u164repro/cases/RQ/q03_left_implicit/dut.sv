// § rangeQueryFoldUnconverted164 — $left onto an implicit net, value 6
module top ();
  parameter [6:3] a = 10;
  assign ccc = $left(a);
endmodule
