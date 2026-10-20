// § paramInitSysArgBitSelAtIndex421
module top #(parameter bit [3:0][3:0] P = 0, parameter W = $bits(P[1])) (output logic [3:0] o);
  assign o = W;
endmodule
