// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  always @(negedge clk) $display("%b", u_y);
  initial $display("%b", u_x);
  assign w = u_x & u_y;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
