// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  always @(posedge clk) begin : nb $display("%b", u_x); end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
