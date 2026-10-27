// § undeclaredReadIfaceBare447
interface ifc #(parameter P) (input clk);
  task automatic t(); $display("%b", u_x); endtask
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(clk); end endmodule
module top; endmodule
