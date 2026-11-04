// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  assign w = u_x;
  wire u_late = 1'b0;
  assign u_late2 = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
