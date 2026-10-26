// § defOnlyAliasVarNoNetType440
module m (a, b);
  typedef logic [3:0] t;
  input t a;
  output t b;
  t z;
  assign b = a;
endmodule
module top; endmodule
