// § bitsParamArgNoFold405
module top; endmodule
module m #(parameter n = 2, parameter k = 3, parameter l = $bits(k)) (input logic [l-1:0] i, output logic [l-1:0] o);
  assign o = i;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
