// § cloneLoopVarClassPropArrayTs238
package p;
  class ov; string nm; int v[2]; endclass
  class b0;
    ov m_w[$];
    int m_fx[3];
  endclass
  class fac extends b0;
    ov m_one;
    extern function int reg_it(string s);
  endclass
  function int fac::reg_it(string s);
    foreach (m_w[i]) reg_it++;
    foreach (m_fx[i]) reg_it += m_fx[i];
    foreach (m_one.v[k]) reg_it += k;
  endfunction
endpackage
package q;
  import p::*;
  class sub extends fac;
    function int more(); return reg_it("q"); endfunction
  endclass
endpackage
module top;
  int x;
  q::sub s;
  initial begin s = new; x = s.more(); end
endmodule
