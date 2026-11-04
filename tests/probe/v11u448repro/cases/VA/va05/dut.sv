// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  task automatic t(); @(posedge clk) $display("%b", undecl_x); endtask
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
