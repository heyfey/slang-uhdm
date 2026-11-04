// § nestedPosInstUdp307
`define MKI(n, o, i) inner n (o, i);
module outer (input logic a, output logic y);
  module inner (output logic o, input logic i); assign o = ~i; endmodule
  `MKI(u_in, y, a)
endmodule
module dut (input logic a, output logic y);
  outer u1 (a, y);
endmodule
