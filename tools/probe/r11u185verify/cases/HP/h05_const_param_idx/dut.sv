// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; logic [7:0] u[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  localparam int P = 1;
  int r1, r2, r3, r4;
  initial begin
    r1 = m.w[2].v;
    r2 = m.w[P].v;
    r3 = m.w[P+1].u[P];
    r4 = m.w[$bits(P) - 30].v;
  end
endmodule
