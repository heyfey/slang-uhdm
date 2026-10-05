// § cloneLoopVarClassPropArrayTs238
// typedef'd queue / dynamic / fixed properties, a two-index fixed array, a static property through the class scope
package p;
  typedef int iq_t[$];
  typedef byte bd_t[];
  typedef int f2_t[2][3];
  class fac;
    iq_t m_q;
    bd_t m_d;
    f2_t m_f;
    static int m_s[$];
    extern function int go();
  endclass
  function int fac::go();
    int n;
    foreach (m_q[i]) n += m_q[i];
    foreach (m_d[i]) n += m_d[i];
    foreach (m_f[i, j]) n += m_f[i][j];
    foreach (fac::m_s[k]) n += k;
    return n;
  endfunction
endpackage
package q;
  import p::*;
  function int g(); fac f = new; return f.go(); endfunction
endpackage
module top;
  int x;
  initial x = q::g();
endmodule
