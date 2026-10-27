// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  initial $display("%b", u_x);
  assign u_x = clk;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
