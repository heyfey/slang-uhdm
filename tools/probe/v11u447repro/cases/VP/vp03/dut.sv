// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  logic r;
  always @(posedge clk) if (u_c) r <= 1'b1;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
