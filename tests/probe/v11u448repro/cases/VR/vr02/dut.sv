// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  assign w = clk ? u_x : u_y;
  initial $display("%b %b", u_y, u_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
