// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  always @(u_ev) $display("x");
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
