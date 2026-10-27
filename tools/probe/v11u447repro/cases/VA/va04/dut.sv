// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  function automatic logic f(logic a); return a; endfunction
  assign w = f(undecl_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
