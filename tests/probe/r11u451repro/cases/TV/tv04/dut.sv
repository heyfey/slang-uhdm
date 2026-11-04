// § taskNameReadImplicitNet451
module m #(parameter P) (input clk);
  task automatic t(); endtask
  logic [3:0] a, y;
  always_comb y = a + t;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
