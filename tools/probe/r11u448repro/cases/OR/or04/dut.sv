// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  wire v;
  initial $display("%b", u_x);
  assign v = 1'b0;
  assign w = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
