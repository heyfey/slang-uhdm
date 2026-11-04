// § invalidReadDefAdmit448
`default_nettype none
module m #(parameter P) (input wire clk);
  initial $display("%b", undecl_x);
endmodule
`default_nettype wire
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
