// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  if (1) begin : g
    initial $display("%b", u_g);
  end
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
