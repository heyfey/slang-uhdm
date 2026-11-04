// § taskNameReadImplicitNet451
module m #(parameter P) (input clk);
  task t; endtask
  always @(posedge clk) if (t) $display("x");
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
