// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  class C #(int N = 1);
    function int g(); return u_c; endfunction
  endclass
  wire w;
  assign w = clk;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
