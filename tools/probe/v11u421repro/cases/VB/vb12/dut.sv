// § bitsDefNoFoldNoTs421
module top #(parameter type T = logic [5:0]) (output logic [7:0] o);
  localparam W = $bits(T);
  T v;
  localparam V = $bits(v);
  assign o = W + V;
endmodule
