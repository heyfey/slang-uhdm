// § nestedPosInstUdp307
module outer (input logic a, b, output logic y);
  module inner (output logic o, input logic i, input logic j); assign o = i & j; endmodule
  inner u_in (y, a & b, 1'b1);
endmodule
module dut (input logic a, b, output logic y);
  outer u1 (a, b, y);
endmodule
