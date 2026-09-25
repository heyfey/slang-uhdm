// § rangeQueryVarDeclMask164v — $high = 20 of a net onto a declared 4-bit wire
module top ();
  wire [20:0] n;
  wire [3:0] w;
  assign w = $high(n);
endmodule
