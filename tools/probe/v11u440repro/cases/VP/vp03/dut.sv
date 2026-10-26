// § undefaultedPlaceholderRetry440
module m #(parameter n, parameter int ws [n-1:0]) (input clk);
  for (genvar i = 0; i < n; i++) begin : g
    logic [ws[i]-1:0] r;
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
