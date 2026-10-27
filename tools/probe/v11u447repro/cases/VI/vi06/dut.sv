// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  logic r;
  always @(posedge clk) if (u_c) r <= 1; else r <= 0;
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
