package p;
  typedef logic [07:00] m_t [00:03];
endpackage
module top import p::*; (input logic [7:0] i, output logic [7:0] o);
  m_t m;
  assign m[0] = i;
  assign o = m[0];
endmodule
