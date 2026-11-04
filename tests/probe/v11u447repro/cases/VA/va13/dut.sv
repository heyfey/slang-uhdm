// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  assign w = u_x;
endmodule
module n #(parameter Q) (input clk);
  wire w;
  assign w = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module n__abstract(); if (0) begin : abstract n not_used(); end endmodule
module top; endmodule
