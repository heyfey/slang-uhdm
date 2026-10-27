// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  function automatic void f(int a);
    typedef logic [1:0] n_t;
    $display("%0d", n_t'(a));
  endfunction
  initial f(3);
  always @(negedge clk) $display("%b", undecl_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
