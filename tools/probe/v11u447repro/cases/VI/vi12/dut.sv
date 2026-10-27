// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  wire w;
  assign w = u_x | clk;
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
