// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  logic c;
  int k, j, r1, r2, r3, r4;
  logic [7:0] bits;
  initial begin
    r1 = m.w[c ? k : j].v;
    r2 = m.w[int'(k)].v;
    r3 = m.w[bits[1:0]].v;
    r4 = m.w[bits[k]].v;
  end
endmodule
