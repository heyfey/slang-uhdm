// § undeclaredReadLaterDecl447
module m #(parameter P) (input clk);
  wire w;
  assign w = late_v;
  logic late_v = 1'b1;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
