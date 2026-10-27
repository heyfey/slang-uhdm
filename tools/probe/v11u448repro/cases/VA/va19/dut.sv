// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial begin int r; r = !undecl_x; r = ~undecl_y; r = -undecl_z; end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
