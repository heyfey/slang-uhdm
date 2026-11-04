// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  initial $display("%b", u_x);
  modport mp(input clk);
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
