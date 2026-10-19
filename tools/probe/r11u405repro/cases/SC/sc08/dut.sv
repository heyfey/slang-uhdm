// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w, parameter x_p = 3) (input logic [7:0] i, output logic [7:0] o);
  localparam l = w'(x_p);
  assign o = w'(i) + l;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
