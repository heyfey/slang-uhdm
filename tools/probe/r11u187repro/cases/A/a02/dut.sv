// § aliasFoldBoundFile183
`include "p.svh"
module top import p::*; (input ctl_t a, output logic [11:0] o);
  assign o = a.imm;
endmodule
