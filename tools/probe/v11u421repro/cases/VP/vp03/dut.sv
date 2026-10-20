// § paramInitSysArgBitSelAtIndex421
module top #(parameter bit [3:0][3:0] P = 0) (output logic [3:0] o);
  localparam W = $bits(P[1][0]);
  assign o = W;
endmodule
