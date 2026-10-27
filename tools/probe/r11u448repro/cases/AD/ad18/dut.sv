// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic a; initial {a, undecl_x} = 2'b0;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
