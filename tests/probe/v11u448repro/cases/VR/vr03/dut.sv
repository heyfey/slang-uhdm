// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  assign w1 = u_x;
  assign w2 = u_y;
  always @(negedge clk) $display("%b", u_y);
  initial $display("%b", u_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
