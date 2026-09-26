// § hierPathSelIdxAtPath178
module top;
  typedef struct packed { logic [3:0] v; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  wire m_t n = m;
  logic [1:0] k;
  logic [3:0] r1, r2;
  assign r1 = n.w[k].v;
  always_comb r2 = n.w[k].v;
endmodule
