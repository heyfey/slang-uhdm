module top (input logic [7:0] i, output logic [7:0] o);
  typedef logic [07:00] m_t [00:03];
  m_t m;
  assign m[0] = i;
  assign o = m[0];
endmodule
