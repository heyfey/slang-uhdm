// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w) (input logic [7:0] i, output logic [7:0] o);
  assign o = (w+1)'(i);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
