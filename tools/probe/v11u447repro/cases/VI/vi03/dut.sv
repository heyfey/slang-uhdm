// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  always @(posedge clk) begin : nb $display("%b", u_x); end
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
