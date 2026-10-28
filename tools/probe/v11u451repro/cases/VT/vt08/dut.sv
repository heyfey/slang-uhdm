// § taskNameReadImplicitNet451
module m #(parameter P) (input clk);
  module nest; task t; endtask initial $display("%b", t); endmodule
  nest u_n();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
