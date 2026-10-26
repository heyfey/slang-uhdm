// § errTypePortSyntaxRange440
module m #(parameter x = "inv", parameter y = 2) (input clk);
  logic [y-1:0][x-1:0] v;
  wire [x-1:0] n;
  logic signed [x-1:0] s;
  bit [x-1:0][y:0] b;
endmodule
module top; endmodule
