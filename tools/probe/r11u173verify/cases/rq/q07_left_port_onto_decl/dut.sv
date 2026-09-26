// § rangeQueryVarDeclMask164v § rangeQueryDeclNetSize164 — $left of an input port onto a declared net
module top(input logic [5:1] a, output wire [2:0] w);
  assign w = $left(a);
endmodule
