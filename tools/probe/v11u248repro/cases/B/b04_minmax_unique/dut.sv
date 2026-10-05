// § cloneWithOperandChainName248
package p;
  parameter int K = 3;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s_t;
  class c;
    c m_sync[$];
    int m_v[$];
    s_t m_s[$];
    int m_a[string];
    int m_k;
    static int m_st;
    function int qget(); return m_k; endfunction
    function c gq(); return this; endfunction
    extern function void f(c a, int lim);
    extern task t(int lim);
  endclass
  function void c::f(c a, int lim);
    int r[$];
    r = m_v.min(x) with (x * m_k);
    r = a.m_v.max with (item[3:0] + lim[1:0]);
    r = m_v.unique(y) with (y[lim -: 2]);
  endfunction
  task c::t(int lim); endtask
endpackage
package q;
  import p::*;
  class u;
    function void g();
      c x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  initial w = new();
endmodule
