// § defOnlyAliasVarNoNetType440
module m (input clk);
  class C; int a; endclass
  C c;
  typedef C ct;
  ct d;
endmodule
module top; endmodule
