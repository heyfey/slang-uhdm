// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k;
  task automatic t(output int o, input int i); o = i; endtask
  initial begin
    t(m.w[k+1].v, m.w[k-1].v);
  end
endmodule
