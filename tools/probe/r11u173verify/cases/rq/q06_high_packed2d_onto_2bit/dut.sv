// § rangeQueryVarDeclMask164v § rangeQueryDeclNetSize164 — $high of a two-dimensional packed variable onto a 2-bit net
module top();
  logic [3:0][7:0] v;
  wire [1:0] w;
  assign w = $high(v);
endmodule
