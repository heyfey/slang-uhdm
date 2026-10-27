// § undeclaredReadImplicitNet447
program p #(parameter P) (input clk);
  initial $display("%b", undecl_x);
endprogram
module p__abstract(); if (0) begin : abstract p not_used(1'b0); end endmodule
module top; endmodule
