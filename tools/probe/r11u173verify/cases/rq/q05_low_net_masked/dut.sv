// § rangeQueryVarDeclMask164v § rangeQueryDeclNetSize164 — $low of a net (bound 9) onto a 3-bit declared net (the mask keeps 1)
module top();
  wire [12:9] n;
  wire [2:0] w;
  assign w = $low(n);
endmodule
