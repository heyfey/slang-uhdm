// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  logic [3:0] arr; logic x;
  always @(posedge clk) x = arr[undecl_i];
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
