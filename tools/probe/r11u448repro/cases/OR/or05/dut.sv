// § implicitNetFirstRefLoc448
module ch(input a); endmodule
module m #(parameter P) (input clk);
  initial $display("%b", u_x);
  ch u1(.a(imp_a));
  assign w = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
