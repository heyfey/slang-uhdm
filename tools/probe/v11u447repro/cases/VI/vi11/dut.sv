// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  initial begin int u_x; u_x = 1; end
  initial $display("%b", u_x);
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
