// § hierPathSelIdxAtPath178
`define G(i) m.w[i+1].v
`define H m.w[k*2].v
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, r1, r2;
  initial begin
    r1 = `G(k);
    r2 = `H;
  end
endmodule
