// § rangeQueryFoldUnconverted164 — $signed onto an implicit net (control: not a range query)
module top ();
  parameter [2:1] a = 2;
  assign ccc = $signed(a);
endmodule
