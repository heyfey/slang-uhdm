// § rangeQueryDeclNetSize164 § rangeQueryVarDeclMask164v — $high = 20 onto a declared 4-bit wire
module top ();
  logic [20:0] a;
  wire [3:0] w;
  assign w = $high(a);
endmodule
