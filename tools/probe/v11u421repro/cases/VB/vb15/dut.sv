// § bitsDefNoFoldNoTs421
module top (input logic [3:0] a, output logic [7:0] o);
  localparam W = $bits({a, 4'b0});
  assign o = W;
endmodule
