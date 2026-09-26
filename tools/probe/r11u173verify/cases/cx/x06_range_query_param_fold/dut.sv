// § rangeQueryFoldUnconverted164 § arrQueryFoldAtBound158 — the same `$high(a)` folded into a parameter and assigned to an implicit net
module top();
  parameter [5:2] a = 10;
  parameter h = $high(a);
  assign ccc = $high(a);
  wire [3:0] w;
  assign w = h;
endmodule
