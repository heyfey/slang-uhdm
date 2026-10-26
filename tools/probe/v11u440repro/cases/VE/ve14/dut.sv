// § errTypePortSyntaxRange440
module m #(parameter x = 4) (input clk);
  reg [x-1:0][0:2] r;
  logic signed [x-1:0][0:2] s;
endmodule
module top; endmodule
