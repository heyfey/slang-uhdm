// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  task automatic t(); $display("%b", u_x); endtask
  initial $display("%b", u_x);
  assign w = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
