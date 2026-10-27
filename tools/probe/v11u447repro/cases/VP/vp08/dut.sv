// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  task automatic t(); $display("%b", u_t); endtask
  initial t();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
