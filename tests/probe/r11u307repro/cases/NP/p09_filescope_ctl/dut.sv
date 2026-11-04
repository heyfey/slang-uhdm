// § nestedPosInstUdp307
module inner (input logic i, output logic o); assign o = ~i; endmodule
module outer (input logic a, output logic y);
  inner u_in (a, y);
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
