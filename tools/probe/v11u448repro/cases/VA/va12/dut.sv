// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic r, r2;
  always_comb r = undecl_x;
  always_ff @(posedge clk) r2 <= undecl_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
