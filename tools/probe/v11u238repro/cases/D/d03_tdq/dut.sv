// § cloneLoopVarClassPropArrayTs238
// a typedef'd queue property and a typedef'd dynamic array property in a class-method clone
package p;
  typedef int iq_t[$];
  typedef int id_t[];
  class fac;
    iq_t m_q;
    id_t m_d;
    extern function int go();
  endclass
  function int fac::go();
    int n;
    n = 0;
    foreach (m_q[i]) n += m_q[i];
    foreach (m_d[j]) n += m_d[j];
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
