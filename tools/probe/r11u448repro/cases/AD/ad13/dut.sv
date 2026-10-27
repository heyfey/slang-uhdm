// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  function automatic logic g(); return 1; endfunction
  initial $display("%b", g);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
