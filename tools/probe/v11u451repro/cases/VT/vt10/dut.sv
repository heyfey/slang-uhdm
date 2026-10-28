// § taskNameReadImplicitNet451
module m #(parameter P) (input clk);
  task t; endtask
  wire w = clk;
  initial $display("%b %b", t, undecl_b);
  assign w2 = undecl_c;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
