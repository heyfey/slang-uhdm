// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  function automatic int f(); int q; q = 2; return q; endfunction
  always @(negedge clk) $display("%d %d", q, f());
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
