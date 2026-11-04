// § nestedPosInstUdp307
module outer (input logic a, output logic y);
  module inner #(parameter bit P = 0) (input logic i, output logic o); assign o = i ^ P; endmodule
  inner #(1) u_in (a, y);
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
