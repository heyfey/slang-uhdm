// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef real r_t;
  typedef int i_t;
  typedef string s_t;
  r_t r; i_t i; s_t s;
endmodule
module top; endmodule
