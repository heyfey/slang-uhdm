// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk);
  typedef bit signed [w-1:0] t;
  t z;
endmodule
module top; m u(.clk(1'b0)); endmodule
