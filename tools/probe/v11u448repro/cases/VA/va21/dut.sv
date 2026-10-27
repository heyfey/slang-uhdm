// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  typedef logic [3:0] nib_t;
  nib_t q;
  initial q = undecl_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
