// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  always_comb if (u_x) ; 
  assign w = u_y;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
