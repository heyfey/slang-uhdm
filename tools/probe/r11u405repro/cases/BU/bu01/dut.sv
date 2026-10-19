// § bitsParamArgNoFold405
module top; endmodule
module m #(parameter n, parameter l = $bits(n)) (input logic [l-1:0] i, output logic [l-1:0] o);
  assign o = i;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
