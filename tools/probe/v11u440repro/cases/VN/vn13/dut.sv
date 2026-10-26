// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] t;
  t z;
  wire t w;
endmodule
module top; m u(.clk(1'b0)); endmodule
