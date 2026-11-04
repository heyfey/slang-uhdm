// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial $display("%b %b", undecl_x, undecl_y);  initial $display("%b", undecl_y);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
