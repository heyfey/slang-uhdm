// § rangeQueryVarDeclMask164v — $right = 9 of an ascending variable onto a declared 2-bit wire
module top ();
  logic [0:9] a;
  wire [1:0] w;
  assign w = $right(a);
endmodule
