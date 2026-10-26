// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] t;
  tri t a;
  wand t b;
  var t c;
  t d = 4'h1;
endmodule
module top; endmodule
