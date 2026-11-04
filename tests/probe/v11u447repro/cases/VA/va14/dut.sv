// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  inner i(.clk(clk));
endmodule
module inner(input clk);
  wire v;
  assign v = u_in;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
