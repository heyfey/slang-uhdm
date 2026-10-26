// § defNetModTdCloneBoundSyntax440
localparam U = 5;
module m #(parameter w = 8) (input clk);
  typedef logic [U-1:0] t;
  t z;
endmodule
module top; m u(.clk(1'b0)); endmodule
