// § rangeQueryFoldUnconverted164 § rangeQueryDeclNetSize164 — $high onto a declared 2-bit wire, value 6
module top ();
  parameter [6:3] a = 10;
  wire [1:0] ccc;
  assign ccc = $high(a);
endmodule
