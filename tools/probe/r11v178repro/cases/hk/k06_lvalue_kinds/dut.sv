// § hierPathSelIdxCloneKeepsElem178v
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  s_t a[4];
  int k, x;
  initial begin
    a[k+1].v++;
    a[k].v--;
    {>>{m.w[k+2].v}} = x;
    m.w[k+3].v <= #1 x;
    m.w[k-1].v *= 2;
    x = m.w[k].v++;
    x = a[k+2].v++ + m.w[k].v;
  end
endmodule
