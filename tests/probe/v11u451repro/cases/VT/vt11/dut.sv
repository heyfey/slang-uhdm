// § taskValBareRefGenNone451v
module m #(parameter P) (input clk);
  task t; endtask
  for (genvar i = 0; i < 2; i++) begin : gl
    initial $display("%b", t);
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
