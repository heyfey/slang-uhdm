// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w, parameter v) (input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  assign o = w'(i);
  assign p = v'(i+1);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
