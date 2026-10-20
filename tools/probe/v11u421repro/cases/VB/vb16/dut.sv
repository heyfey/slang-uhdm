// § bitsDefNoFoldNoTs421
module top (input logic [3:0] a, output logic [7:0] o);
  localparam W = $bits({2{a}});
  assign o = W;
endmodule
