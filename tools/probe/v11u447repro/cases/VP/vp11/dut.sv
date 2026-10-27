// § undeclaredReadLaterDecl447
module m #(parameter P) (input clk);
  initial $display("%b", late_r);
  logic late_r;
  initial $display("%b", late_p);
  localparam late_p = 1;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
