// § rangeQueryFoldUnconverted164 § rangeQueryDeclNetSize164 — $high of a parameter onto a continuously assigned VARIABLE
module top();
  parameter [6:3] a = 5;
  logic [2:0] v;
  assign v = $high(a);
endmodule
