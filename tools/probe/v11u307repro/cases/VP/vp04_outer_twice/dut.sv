// § nestedPosInstUdp307
module outer (input logic a, b, output logic y);
  module inner (output logic o, input logic i, input logic j); assign o = i & j; endmodule
  inner u_in (y, a, b);
endmodule
module dut (input logic [1:0] a, b, output logic [1:0] y);
  outer u1 (a[0], b[0], y[0]);
  outer u2 (a[1], b[1], y[1]);
endmodule
