// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  initial begin int q; q = u_x + 1; end
  assign w = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
