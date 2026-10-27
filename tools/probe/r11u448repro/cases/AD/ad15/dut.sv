// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  function automatic int f(); enum {EA, EB} e; e = EB; return e; endfunction
  initial $display("%d", EB);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
