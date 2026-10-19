// § bitsParamArgNoFold405
module top #(parameter int items_p = 5) (output logic [31:0] o);
  localparam lg = $bits(items_p);
  assign o = lg;
endmodule
