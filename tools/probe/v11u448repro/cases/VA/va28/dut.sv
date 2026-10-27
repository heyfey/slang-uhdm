// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial begin : b logic [3:0] undecl_x; undecl_x = 4'h1; end
  assign w = undecl_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
