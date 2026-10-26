// § errTypePortSyntaxRange440
module m (a, q, a2);
  parameter x = 4;
  input logic [x-1:0][0:2] a;
  output reg [x-1:0][0:2] q;
  input [x-1:0][0:2] a2;
endmodule
module top; endmodule
