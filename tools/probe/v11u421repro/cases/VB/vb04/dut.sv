// § bitsDefNoFoldNoTs421
module top (output logic [7:0] o);
  logic [3:0] arr [0:2];
  localparam W = $bits(arr);
  assign o = W;
endmodule
