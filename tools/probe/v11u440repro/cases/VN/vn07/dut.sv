// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] t;
  t z;
  wire t w;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
