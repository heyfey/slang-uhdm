// § rangeQueryFoldUnconverted164 — two-argument $high of a multi-dimensional packed array
module top ();
  logic [3:0][7:0] a;
  assign ccc = $high(a, 2);
endmodule
