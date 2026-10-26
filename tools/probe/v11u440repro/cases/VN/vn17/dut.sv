// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] t;
  wire t a, b, c;
  tri t d, e;
endmodule
module top; m u(.clk(1'b0)); endmodule
