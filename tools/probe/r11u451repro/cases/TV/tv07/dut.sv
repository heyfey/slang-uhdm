// § taskNameReadImplicitNet451
module m #(parameter P) (input clk);
  task automatic t(); endtask
  initial $display("%b %b", undecl_u, t);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
