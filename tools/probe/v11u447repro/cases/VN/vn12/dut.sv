// § undeclaredReadImplicitNet447
interface ifc #(parameter P) (input clk);
  function automatic void f(); enum {IX} e; endfunction
  initial $display("%d", IX);
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
