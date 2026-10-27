// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic [1:0] sel; logic r;
  always_comb case (sel) undecl_x: r = 1; default: r = 0; endcase
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
