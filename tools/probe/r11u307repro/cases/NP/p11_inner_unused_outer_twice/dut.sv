// § nestedPosInstUdp307
module outer (input logic a, output logic y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  inner u_in (a, y);
endmodule
module dut (input logic [2:0] a, output logic [2:0] y);
  outer u1 (.a(a[0]), .y(y[0]));
  outer u2 (.a(a[1]), .y(y[1]));
  outer u3 (.a(a[2]), .y(y[2]));
endmodule
