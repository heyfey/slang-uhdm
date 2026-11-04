// § trailIdxCallArgNamesByPath187 (control: a direct index reference and its typespec reference)
module top(input int k, input int j, output logic o, output logic p);
  typedef struct packed { logic [3:0] q; logic [3:0] w; } m_t;
  m_t m;
  assign o = m.q[k];
  assign p = m.w[k + j];
endmodule
