// § bitsParamArgNoFold405
module top #(parameter items_p = 4'd5) (output logic [31:0] o);
  localparam int lg = $bits(items_p);
  assign o = lg;
endmodule
