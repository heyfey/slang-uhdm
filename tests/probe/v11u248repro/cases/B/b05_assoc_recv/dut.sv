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
    string ks[$];
    int is[$];
    ks = m_a.find_first_index(k) with (k > lim && k.index() != "x");
    is = a.m_a.find(v) with (v == lim);
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
