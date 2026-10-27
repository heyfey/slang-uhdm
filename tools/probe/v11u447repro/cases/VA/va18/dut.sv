// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  function automatic logic f(); return u_f; endfunction
  assign w = f();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
