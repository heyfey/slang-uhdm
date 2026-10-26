// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk);
  typedef logic [w-1:0] t;
  typedef t t2;
  t2 z;
endmodule
module top; m u(.clk(1'b0)); endmodule
