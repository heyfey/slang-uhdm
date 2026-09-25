// § rangeQueryVarDeclMask164v — $high of a sized-literal bound onto a declared 4-bit wire (the law abstains)
module top ();
  logic [5'd20:0] a;
  wire [3:0] w;
  assign w = $high(a);
endmodule
