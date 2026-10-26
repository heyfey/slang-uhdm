// § errTypeTsLocAsVector440v
module m #(parameter x = "inv") (input clk);
  logic [x-1:0][0:2] v;
  wire [x-1:0] n2 = 0;
endmodule
module top; endmodule
