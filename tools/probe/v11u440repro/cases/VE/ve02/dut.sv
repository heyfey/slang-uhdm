// § errTypePortSyntaxRange440
module m #(parameter x = "inv") (input clk, output reg [x-1:0] q);
  wire signed [x-1:0] n;
  reg [x-1:0][1:0] r;
endmodule
module top; endmodule
