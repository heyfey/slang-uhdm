// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial $display("%b", undecl_x);
endmodule
module n #(parameter Q) (input clk);
  initial $display("%b", undecl_x);
endmodule
module n__abstract(); if (0) begin : abstract n not_used(); end endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
