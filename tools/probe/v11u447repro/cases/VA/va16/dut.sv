// § undeclaredReadLaterDecl447
module m #(parameter P) (input clk);
  wire [3:0] w;
  assign w = late_w;
  wire [3:0] late_w;
  assign late_w = 4'h3;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
