// § errTypePortSyntaxRange440
module m #(parameter x = "inv", parameter y = 4) (input clk);
  logic [x-1:0] v;
  logic [y-1:0] ok;
  bit signed [x:1] b;
endmodule
module top; endmodule
