// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic r;
  initial begin r <= 1'b1; undecl_q = r; end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
