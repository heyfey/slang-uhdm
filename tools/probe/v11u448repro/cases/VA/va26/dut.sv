// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  function automatic int f(); localparam int LP = 2; return LP; endfunction
  initial $display("%d", LP);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
