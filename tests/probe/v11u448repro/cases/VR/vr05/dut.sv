// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  assign w = u_x;
  initial begin
    $display("%b",
      u_x);
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
