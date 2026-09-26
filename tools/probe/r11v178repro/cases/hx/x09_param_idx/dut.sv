// § hierPathSelIdxAtPath178
module top #(parameter int P = 2);
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  localparam int Q = 1;
  m_t m;
  int r1, r2, r3;
  initial begin
    r1 = m.w[P-1].v;
    r2 = m.w[Q+P].v;
    r3 = m.w[$bits(r1)-31].v;
  end
endmodule
