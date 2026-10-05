// § cloneLoopVarClassPropArrayTs238
package p;
  class fac;
    protected string m_w[$];
    protected int m_d[];
    extern function int reg_it(string s);
  endclass
  function int fac::reg_it(string s);
    foreach (m_w[i]) if (m_w[i] == s) reg_it++;
    foreach (this.m_d[j]) reg_it += m_d[j];
  endfunction
endpackage
import p::*;
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
