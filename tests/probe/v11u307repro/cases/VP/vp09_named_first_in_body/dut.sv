// § nestedPosInstUdp307
module outer (input logic [1:0] a, output logic [1:0] y);
  module inner (output logic o, input logic i); assign o = ~i; endmodule
  inner u_b (.o(y[1]), .i(a[1]));
  inner u_a (y[0], a[0]);
endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  outer u1 (a[1:0], y[1:0]);
  outer u2 (a[3:2], y[3:2]);
endmodule
