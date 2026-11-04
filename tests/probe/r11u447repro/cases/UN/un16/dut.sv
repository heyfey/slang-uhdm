// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  task automatic t(input logic v); $display("%b", v); endtask
  initial t(undecl_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
