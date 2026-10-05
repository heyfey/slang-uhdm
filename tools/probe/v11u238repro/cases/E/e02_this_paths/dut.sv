// § cloneLoopVarClassPropArrayTs238
// this. paths over class-property arrays and strings inside import clones, nested for inside foreach
package p;
  class c;
    int m_q[$];
    string m_s;
    int m_f[3];
    extern function int go();
  endclass
  function int c::go();
    int n;
    n = 0;
    foreach (this.m_q[i])
      for (int k = 0; k < i; k++) n += this.m_q[k];
    foreach (this.m_s[j]) n++;
    foreach (this.m_f[j]) n += m_f[j];
    return n;
  endfunction
endpackage
package q;
  import p::*;
  function int g(); c o = new; return o.go(); endfunction
endpackage
module top;
  int r;
  initial r = q::g();
endmodule
