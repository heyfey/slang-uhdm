// § rangeQueryFoldUnconverted164 § rangeQueryDeclNetSize164 — $high onto a declared 8-bit wire (control)
module top ();
  parameter [2:1] a = 10;
  wire [7:0] ccc;
  assign ccc = $high(a);
endmodule
