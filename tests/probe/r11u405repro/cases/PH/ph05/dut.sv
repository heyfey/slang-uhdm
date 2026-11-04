// § hierSelWidthLocalKeep405
module top; endmodule
module m #(parameter w) (input logic [w-1:0] i, output logic [7:0] o);
  logic [4:0] c;
  assign o = c[($bits(c)-1)-:(1+w)];
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
