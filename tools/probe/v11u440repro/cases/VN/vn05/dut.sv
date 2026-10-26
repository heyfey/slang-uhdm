// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] t;
  if (1) begin : g
    t z;
    wire t w;
  end
endmodule
module top; endmodule
