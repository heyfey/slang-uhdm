// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  logic r;
  always @(posedge clk) r <= u_x & u_y;
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
