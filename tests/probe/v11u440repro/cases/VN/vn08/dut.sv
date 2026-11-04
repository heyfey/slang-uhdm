// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] t;
  t z;
  wire t w;
endmodule
module top; if (0) begin : abstract m not_used(.clk(1'b0)); end endmodule
