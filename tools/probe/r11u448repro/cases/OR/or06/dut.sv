// § implicitNetFirstRefLoc448
module m #(parameter P) (input clk);
  function automatic int f(); return u_x; endfunction
  assign w = u_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
