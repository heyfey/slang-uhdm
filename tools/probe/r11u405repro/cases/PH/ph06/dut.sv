// § hierSelWidthLocalKeep405
module top #(parameter w = 2) (input logic [w-1:0] i, output logic [7:0] o);
  logic [4:0] c;
  assign o = c[($bits(c)-1)-:(1+w)];
endmodule
