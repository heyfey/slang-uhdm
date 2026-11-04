// § implicitNetDefaultType485
`default_nettype wand
module m #(parameter P) (input clk);
  task automatic t(); endtask
  initial $display("%b", t);
endmodule
`default_nettype wire
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
