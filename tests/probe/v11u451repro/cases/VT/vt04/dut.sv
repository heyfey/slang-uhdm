// § taskNameReadImplicitNet451
module m #(parameter P) (input clk);
  task t; endtask
  task u; endtask
  initial begin $display("%b", u); $display("%b", undecl_k); $display("%b", t); $display("%b", u); end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
