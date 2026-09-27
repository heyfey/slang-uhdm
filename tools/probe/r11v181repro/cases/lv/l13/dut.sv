// § classMethodLvIsProcess181 § lvSelIdxChainName181 § procLvIdxCallWholeSpan181 (v11u181 break: a top-level class method's lvalue paths: call, operation, local-variable base)
typedef struct { int v; } s_t;
typedef struct { s_t w[4]; } m_t;
class C;
  m_t q;
  function int h(int x); return x; endfunction
  function void g(int j);
    m_t l;
    q.w[j].v = 1;
    q.w[h(j)].v = 2;
    q.w[j*2].v += 3;
    l.w[j].v = 4;
    q.w[j].v++;
  endfunction
endclass
module top; initial begin C c = new; c.g(1); end endmodule
