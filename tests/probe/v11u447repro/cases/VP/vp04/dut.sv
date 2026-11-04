// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  logic [1:0] r;
  always_comb case (r) u_k: $display("k"); default: ; endcase
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
