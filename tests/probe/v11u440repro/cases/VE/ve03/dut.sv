// § errTypePortSyntaxRange440
module m #(parameter x = "inv") (input clk);
  logic [x-1:0] v [2];
  logic [x-1:0] u = '0;
endmodule
module top; endmodule
