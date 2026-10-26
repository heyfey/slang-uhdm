// § defOnlyAliasVarNoNetType440
module m #(parameter n = 2) (input clk);
  typedef logic [3:0] t;
  if (n > 1) begin : g
    t z;
  end
  t q [2];
endmodule
module top; endmodule
