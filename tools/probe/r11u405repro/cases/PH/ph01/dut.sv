// § hierSelWidthLocalKeep405
module top; endmodule
module m #(parameter n) (input logic [7:0] i, output logic [7:0] o);
  typedef logic [$clog2(n)-1:0] t_t;
  t_t x;
  assign o = i + x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
