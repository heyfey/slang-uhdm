// § implicitNetDefaultType485
`default_nettype tri
module m #(parameter P) (input clk);
  always @(negedge clk) $display("%b", undecl_x);
endmodule
`default_nettype wire
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
