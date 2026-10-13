// § nestedPosInstUdp307
module outer (input logic a, output logic y);
  module inner #(parameter int D = 0) (output logic o, input logic i); assign o = i; endmodule
  inner #(1_0) u_in (y, a);
endmodule
module dut (input logic a, output logic y);
  outer u1 (a, y);
endmodule
