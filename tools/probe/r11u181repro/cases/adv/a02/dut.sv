// § incDecMixedPathIsLvalue181 § lvSelIdxChainName181 § classMethodLvIsProcess181 § lvIdxMixedPathIsRead181 — break hunt: this-rooted and nested-path inc/dec operands, an inc/dec inside a select index, an inc/dec as a call argument
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, x, arr [8];
  function automatic int f(int a); return a; endfunction
  class C;
    m_t q;
    function void g(int j);
      this.q.w[j].v++;
      q.w[q.w[j].v].v--;
    endfunction
  endclass
  initial begin
    C c = new;
    arr[m.w[k].v++] = 1;
    x = f(m.w[k+1].v++);
    m.w[m.w[k].v].v++;
    c.g(k);
  end
endmodule
