// § invalidReadDefAdmit448
module m #(parameter P, parameter S = "inv") (input clk);
  logic [7:0] r;
  always @(posedge clk) r <= r[S:0] + undecl_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
