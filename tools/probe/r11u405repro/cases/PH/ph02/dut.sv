// § hierSelWidthLocalKeep405
module top; endmodule
module m #(parameter n, parameter l = $clog2(n)) (input logic [15:0] i, output logic [7:0] o);
  assign o = i[4+:l];
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
