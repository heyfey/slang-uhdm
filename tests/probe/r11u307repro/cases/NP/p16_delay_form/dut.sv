// § nestedPosInstUdp307
module outer (input logic a, output logic y);
  module inner #(parameter int P = 0) (input logic i, output logic o); assign o = ~i; endmodule
  inner #(2) u_in (y, a);
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
