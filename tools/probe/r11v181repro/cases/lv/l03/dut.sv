// § classMethodLvIsProcess181 § lvSelIdxChainName181 § procLvIdxCallWholeSpan181 (v11u181 break: class methods: extern body, static method, a local struct lvalue, call indices)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  class C;
    m_t q;
    m_t arr;
    extern function void g(int j);
    static function void sf(ref m_t r, input int j);
      r.w[j].v = 5;
    endfunction
    function int h(int x); return x; endfunction
    function void loc(int j);
      m_t l;
      l.w[j].v = 3;
      arr.w[h(j)].v = 2;
      arr.w[j].v += h(j);
    endfunction
  endclass
  function void C::g(int j);
    q.w[j].v = 1;
    arr.w[j+1].v = 2;
  endfunction
  initial begin C c = new; c.g(1); end
endmodule
