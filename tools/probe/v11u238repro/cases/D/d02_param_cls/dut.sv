// § cloneLoopVarClassPropArrayTs238
// a parameterized class's queue of strings, a packed-array property (control), an inherited dynamic array via this.
package p;
  class base; int m_dyn[]; endclass
  class pc #(type T = int) extends base;
    T m_tq[$];
    bit [7:0] m_pk;
    extern function int go();
  endclass
  function int pc::go();
    int n;
    foreach (m_tq[i]) n++;
    foreach (m_pk[i]) n += m_pk[i];
    foreach (this.m_dyn[i]) n += this.m_dyn[i];
    return n;
  endfunction
endpackage
package q;
  import p::*;
  function int g(); pc #(string) f = new; return f.go(); endfunction
endpackage
module top;
  int x;
  initial x = q::g();
endmodule
