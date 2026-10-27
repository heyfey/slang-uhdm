// § implicitNetFirstRefLoc448
`define RD u_x
module m #(parameter P) (input clk);
  initial $display("%b", `RD);
  assign w = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
