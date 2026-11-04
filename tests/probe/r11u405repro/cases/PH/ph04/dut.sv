// § hierSelWidthLocalKeep405
module top; endmodule
module m #(parameter n, parameter k = 3) (input logic [15:0] i, output logic [7:0] o);
  localparam l = $clog2(n) + 1;
  assign o = i[k +: l];
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
