// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire [3:0] w;
  assign w = {2{u_x}};
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
