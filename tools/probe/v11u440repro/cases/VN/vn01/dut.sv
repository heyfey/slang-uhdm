// § defOnlyAliasVarNoNetType440
module m #(parameter type T = logic [3:0]) (input clk);
  T z;
  wire T w;
endmodule
module top; endmodule
