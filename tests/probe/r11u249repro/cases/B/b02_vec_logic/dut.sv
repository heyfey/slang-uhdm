// § modTdElabFoldSize249
module top(input logic [7:0] a, output logic [7:0] o);
  typedef logic [7:0] m_t[2];
  m_t m;
  assign m[0] = a;
  assign m[1] = ~a;
  assign o = m[0] ^ m[1];
endmodule
