// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk);
  if (1) begin : g
    typedef logic [w-1:0] t;
    t z;
  end
endmodule
module top; m u(.clk(1'b0)); endmodule
