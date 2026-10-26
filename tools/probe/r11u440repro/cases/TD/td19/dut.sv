// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk);
  typedef logic [w-1:0] t;
  t z, y;
  wire t n;
endmodule
module top; m u1(.clk(1'b0)); m u2(.clk(1'b1)); endmodule
