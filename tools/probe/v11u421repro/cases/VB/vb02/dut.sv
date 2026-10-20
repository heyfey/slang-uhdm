// § bitsDefNoFoldNoTs421
module top (output logic [7:0] o);
  localparam W = $bits(4'b0);
  assign o = W;
endmodule
