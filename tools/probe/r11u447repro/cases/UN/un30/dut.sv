// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  always @(negedge clk) $display("%b", undecl_x);
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
