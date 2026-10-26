// § defOnlyAliasVarNoNetType440
module m #(parameter w) (input clk);
  typedef logic [3:0] t;
  t z;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
