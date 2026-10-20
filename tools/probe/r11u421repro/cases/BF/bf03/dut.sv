// § bitsDefNoFoldNoTs421
module top #(parameter type T = logic [3:0]) (input logic a);
  localparam W = $bits(T);
endmodule
