// § taskValBareRefGenNone451v
module m #(parameter P) (input clk);
  task t; endtask
  generate
    initial $display("%b", t);
  endgenerate
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
