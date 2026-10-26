// § errTypePortSyntaxRange440
module m (a, b);
  parameter x = "inv";
  input [x-1:0] a;
  output reg [x-1:0] b;
endmodule
module top; endmodule
