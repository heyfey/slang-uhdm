// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] a_t [2];
  a_t x;
endmodule
module top; endmodule
