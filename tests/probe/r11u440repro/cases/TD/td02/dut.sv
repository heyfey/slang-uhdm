// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8, parameter n = 1) (input clk);
  typedef logic [w*n-1:0] t;
  t z;
  logic [w*n-1:0] y;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
