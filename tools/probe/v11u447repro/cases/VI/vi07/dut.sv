// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  always @(posedge clk) $display("%b", late_x);
  logic late_x;
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
