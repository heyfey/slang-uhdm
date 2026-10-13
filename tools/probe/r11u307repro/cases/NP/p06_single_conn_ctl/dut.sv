// § nestedPosInstUdp307
module outer (output logic y);
  module inner (output logic o); assign o = 1'b1; endmodule
  inner u_in (y);
endmodule
module dut (output logic y);
  outer u1 (.y(y));
endmodule
