// § cloneLoopVarClassPropArrayTs238
// a two-index fixed property, a queue of strings, a dynamic array of class handles in a class-method clone
package p;
  class it; int v; endclass
  class fac;
    int m_f[2][3];
    string m_sq[$];
    it m_h[];
    extern function int go();
  endclass
  function int fac::go();
    int n;
    n = 0;
    foreach (m_f[i, j]) n += m_f[i][j];
    foreach (m_sq[k]) n += m_sq[k].len();
    foreach (m_h[k]) n += m_h[k].v;
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
