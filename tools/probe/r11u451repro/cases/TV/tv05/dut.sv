// § taskNameReadImplicitNet451
module m #(parameter P) (input clk);
  function automatic int f(); return 3; endfunction
  initial $display("%b", f);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
