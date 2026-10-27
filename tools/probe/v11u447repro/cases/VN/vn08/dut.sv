// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  task automatic t(input int ta); endtask
  assign w = ta;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
