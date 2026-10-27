// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  logic x;
  always @(posedge clk) x <= undecl_x & undecl_y;
  initial $display("%b", undecl_x);
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
