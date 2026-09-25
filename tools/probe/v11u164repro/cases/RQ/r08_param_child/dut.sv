// § rangeQueryFoldUnconverted164 § rangeQueryVarDeclMask164v — $high in a parameterised child, two specialisations
module m #(parameter N = 4) (output o);
  logic [N-1:0] a;
  assign o = $high(a);
endmodule
module top (output o1, output o2);
  m #(8) u1(o1);
  m u2(o2);
endmodule
