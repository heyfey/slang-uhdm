// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  sub u_s(.a(clk));
  initial $display("%b", undecl_x);
endmodule
module sub(input a); initial $display("%b", a); endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
