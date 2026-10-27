// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  function automatic int f(); int u; u = 1; return u; endfunction
  initial $display("%d", u);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
