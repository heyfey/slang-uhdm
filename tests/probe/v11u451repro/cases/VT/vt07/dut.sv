// § taskValBareRefGenNone451v
`default_nettype none
module m #(parameter P) (input wire clk);
  task t; endtask
  initial $display("%b", t);
endmodule
`default_nettype wire
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
