// § taskValBareRefGenNone451v
module m #(parameter P) (input clk);
  task t; endtask
  initial $display("%b", t);
  if (1) begin : g
    wire w;
    assign w = t;
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
