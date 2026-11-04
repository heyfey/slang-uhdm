// § invalidReadDefAdmit448
interface ifc #(parameter P) (input clk);
  initial $display("%b", undecl_x);
endinterface
module ifc__abstract(); if (0) begin : abstract ifc not_used(1'b0); end endmodule
module top; endmodule
