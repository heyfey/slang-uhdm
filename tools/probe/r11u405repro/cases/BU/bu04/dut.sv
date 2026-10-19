// § bitsParamArgNoFold405
module top; endmodule
module m #(parameter n, parameter l = $bits(n+1)) (input logic [7:0] i, output logic [7:0] o);
  assign o = i + l;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
