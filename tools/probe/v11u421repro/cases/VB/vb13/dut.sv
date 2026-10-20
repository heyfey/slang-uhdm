// § bitsDefNoFoldNoTs421
module top (output logic [7:0] o);
  localparam W = $bits("abc");
  assign o = W;
endmodule
