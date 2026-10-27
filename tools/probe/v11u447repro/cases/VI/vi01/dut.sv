// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  function automatic logic f(); return u_x; endfunction
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
