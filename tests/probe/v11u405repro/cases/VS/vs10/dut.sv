// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w) (input logic [7:0] i, output logic [7:0] o);
  localparam q = w'(5);
  assign o = i + q + w'(i);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
