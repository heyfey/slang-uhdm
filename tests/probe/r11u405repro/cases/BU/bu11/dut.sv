// § bitsParamArgNoFold405
module top (input logic [3:0] i, output logic [3:0] o);
  localparam k = 3;
  localparam l = $bits(k);
  assign o = i + l;
endmodule
