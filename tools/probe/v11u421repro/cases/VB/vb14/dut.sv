// § bitsDefNoFoldNoTs421
module top (input logic [3:0] a, output logic [7:0] o);
  localparam W = $bits(a[2:0]);
  localparam V = $bits(a[1]);
  assign o = W + V;
endmodule
