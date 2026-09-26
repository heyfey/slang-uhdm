// § rangeQueryFoldUnconverted164 § rangeQueryDeclNetSize164 — $left of a parameter onto a wider declared net
module top();
  parameter [9:3] p = 7;
  wire [15:0] w;
  assign w = $left(p);
endmodule
