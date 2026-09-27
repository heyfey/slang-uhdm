// § classMethodLvIsProcess181 § lvSelIdxChainName181 (v11u181 break: streaming lvalue and plain lvalue in the same class method, inc/dec and shift-assign in a class method)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  class C;
    m_t m;
    int x;
    function void f(int k);
      {>>{m.w[k].v}} = x;
      m.w[k+1].v = x;
      m.w[k].v++;
      m.w[k].v <<= 1;
    endfunction
  endclass
  initial begin C c = new; c.f(0); end
endmodule
