// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  function automatic int f(); #1; return 0; endfunction
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
