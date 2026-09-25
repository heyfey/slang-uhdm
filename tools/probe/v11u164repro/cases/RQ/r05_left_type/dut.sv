// § rangeQueryFoldUnconverted164 — $left of a typedef onto an implicit net
module top ();
  typedef logic [5:2] t_t;
  assign ccc = $left(t_t);
endmodule
