// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk);
  typedef bit [w-1:0] t;
  t z;
  t q [2];
endmodule
module top; m u(.clk(1'b0)); endmodule
