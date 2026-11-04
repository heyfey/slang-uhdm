// § bitsParamArgNoFold405
module top #(parameter logic [11:0] v = 1) (output logic [$bits(v)-1:0] o);
  localparam w = $bits(v);
  assign o = w;
endmodule
