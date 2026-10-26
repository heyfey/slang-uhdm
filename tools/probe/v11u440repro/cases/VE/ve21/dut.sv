// § errTypeTsLocAsVector440v
module m (a, b, c);
  parameter x = "inv";
  input [x-1:0][0:2] a;
  output [x-1:0][0:2] b;
  input wire [x-1:0][0:2] c;
endmodule
module top; endmodule
