// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic [3:0] v; initial v = {undecl_x, 3'b0};
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
