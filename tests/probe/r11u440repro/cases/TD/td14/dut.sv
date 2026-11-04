// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk);
  typedef logic [w-1:0] t;
  t z;
endmodule
module top; m #(.w(4)) u(.clk(1'b0)); endmodule
