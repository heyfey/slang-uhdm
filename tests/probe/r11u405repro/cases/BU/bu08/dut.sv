// § bitsParamArgNoFold405
module top #(parameter k = 3, parameter l = $bits(k)) (input logic [l-1:0] i, output logic [l-1:0] o);
  assign o = i;
endmodule
