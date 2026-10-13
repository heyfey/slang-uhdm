// § nestedPosInstUdp307
module outer (input logic a, b, output logic y, z);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  inner u_in (a, y), u_jn (b, z);
endmodule
module dut (input logic a, b, output logic y, z);
  outer u1 (.a(a), .b(b), .y(y), .z(z));
endmodule
