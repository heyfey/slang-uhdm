// § rangeQueryDeclNetSize164 § rangeQueryVarDeclMask164v — $high = 6 of a variable onto a declared 2-bit wire
module top ();
  logic [6:3] a;
  wire [1:0] w;
  assign w = $high(a);
endmodule
