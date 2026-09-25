// § rangeQueryFoldUnconverted164 § rangeQueryDeclNetSize164 — $high onto a declared one-bit wire
module top ();
  parameter [2:1] a = 10;
  wire ccc;
  assign ccc = $high(a);
endmodule
