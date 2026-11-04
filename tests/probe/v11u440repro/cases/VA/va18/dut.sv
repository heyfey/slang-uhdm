// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk);
  typedef logic [w-1:w/2] t;
  t z;
endmodule
module top; m u(.clk(1'b0)); endmodule
