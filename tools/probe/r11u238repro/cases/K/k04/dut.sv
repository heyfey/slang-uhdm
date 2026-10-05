// § cloneLoopVarClassPropArrayTs238
package p;
  class ov; string nm; endclass
  class fac;
    protected ov m_w[$];
    protected int m_d[];
    protected int m_f[4];
    protected int m_a[string];
    extern function int reg_it(string s);
  endclass
  function int fac::reg_it(string s);
    int n = 0;
    foreach (m_w[i]) if (m_w[i].nm == s) n++;
    foreach (m_d[j]) n += m_d[j];
    foreach (m_f[k]) n += m_f[k];
    foreach (m_a[q]) n++;
    return n;
  endfunction
endpackage
package q;
  import p::*;
  function int g();
    fac f = new;
    return f.reg_it("x");
  endfunction
endpackage
module top;
  int x;
  initial x = q::g();
endmodule
