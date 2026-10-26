// § errTypePortSyntaxRange440
module m #(parameter x = 4) (input clk);
  logic [x-1:0][0:2] v;
  wire [x-1:0] n2 = 0;
endmodule
module top; endmodule
