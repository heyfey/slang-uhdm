// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter int w) (input logic [7:0] i, output logic [7:0] o);
  assign o = w'(i);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
