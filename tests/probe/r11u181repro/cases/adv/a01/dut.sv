// § lvSelIdxChainName181 § classMethodLvIsProcess181 § lvIdxMixedPathIsRead181 — break hunt: a streaming lvalue, a nested path index, a compound assignment and a nonblocking lvalue in a class method and a module initial
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m, n;
  int k, x;
  class C;
    m_t q; int x;
    function void g(int j);
      {>>{q.w[j+1].v}} = x;
      q.w[q.w[j].v].v = 1;
      q.w[j*2].v += 3;
    endfunction
  endclass
  initial begin
    C c = new;
    {>>{m.w[k+2].v}} = x;
    m.w[n.w[k].v + 1].v = 2;
    m.w[k+3].v <= x;
    c.g(k);
  end
endmodule
