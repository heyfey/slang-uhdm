// § bitsDefNoFoldNoTs421
module top #(parameter w_p = 4) (input logic [w_p-1:0] a, output logic [7:0] o);
  localparam W = $bits(a);
  assign o = W;
endmodule
