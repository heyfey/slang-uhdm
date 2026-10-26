// § errTypePortSyntaxRange440
module m #(parameter w = 2, x = "inv", y = 3) (
  input [y-1:0][x-1:0][w-1:0] a,
  output [x-1:0] b);
  assign b = '0;
endmodule
module top; endmodule
