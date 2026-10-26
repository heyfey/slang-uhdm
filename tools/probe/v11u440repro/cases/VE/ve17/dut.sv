// § errTypePortSyntaxRange440
module m #(parameter x = 4) (input clk);
  wire [x-1:0][0:2] n;
  wire logic [x-1:0][0:2] wl;
  var [x-1:0][0:2] v;
endmodule
module top; endmodule
