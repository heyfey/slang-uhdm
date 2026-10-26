// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic t;
  typedef bit b_t;
  t z; b_t b;
  wire t w;
  wor t wo;
endmodule
module top; endmodule
