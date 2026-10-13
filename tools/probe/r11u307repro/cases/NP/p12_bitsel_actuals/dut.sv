// § nestedPosInstUdp307
module outer (input logic [1:0] a, output logic [1:0] y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  inner u_in (a[0], y[1]);
  assign y[0] = a[1];
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u1 (.a(a), .y(y));
endmodule
