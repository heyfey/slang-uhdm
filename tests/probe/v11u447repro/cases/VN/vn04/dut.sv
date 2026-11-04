// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  assign w = LATE_U;
endmodule
parameter LATE_U = 1;
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
