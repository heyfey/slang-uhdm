// § rangeQueryFoldUnconverted164 — $low of a localparam onto an implicit net
module top();
  localparam logic [11:4] L = 8'hA5;
  assign r = $low(L);
endmodule
