// § rangeQueryVarDeclMask164v — $low = 3 of a variable onto a declared 1-bit wire
module top ();
  logic [7:3] a;
  wire w;
  assign w = $low(a);
endmodule
