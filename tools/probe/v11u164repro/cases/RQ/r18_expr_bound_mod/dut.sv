// § rangeQueryVarDeclMask164v — $high of an expression bound onto a declared 2-bit wire (the law abstains)
module top ();
  localparam N = 7;
  logic [N-1:0] a;
  wire [1:0] w;
  assign w = $high(a);
endmodule
