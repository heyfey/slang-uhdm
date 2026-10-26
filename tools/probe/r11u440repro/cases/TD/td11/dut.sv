// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8, parameter n = 1) (input clk);
  typedef logic [7:0] t;
  t z;
endmodule
module top; m u(.clk(1'b0)); endmodule
