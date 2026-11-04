// § cloneLoopVarClassPropArrayTs238
// a static queue property read through the class scope and through a handle in a class-method clone
package p;
  class fac;
    static int m_s[$];
    int m_o[$];
    extern function int go(fac other);
  endclass
  function int fac::go(fac other);
    int n;
    n = 0;
    foreach (fac::m_s[k]) n += k;
    foreach (other.m_o[k]) n += other.m_o[k];
    return n;
  endfunction
endpackage
package q;
  import p::*;
  function int g(); fac f = new; return f.go(f); endfunction
endpackage
module top;
  int x;
  initial x = q::g();
endmodule
