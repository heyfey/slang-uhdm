// § undeclaredReadLaterDecl447
module m #(parameter P) (input clk);
  initial $display("%b", late_v);
  logic [3:0] late_v;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
