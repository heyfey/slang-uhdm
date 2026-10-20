// § bitsDefNoFoldNoTs421
module top (input logic [3:0] a, b, input logic c, output logic [7:0] o);
  localparam W = $bits(a[1+:2]);
  assign o = W;
endmodule
