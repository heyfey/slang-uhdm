// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic r; always @(posedge clk) case (undecl_x) 1: r = 1; default: r = 0; endcase
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
