// § cloneLoopVarClassPropStringTs248
package p;
  class c;
    string m_a;
    static string m_s;
    local string m_l, m_m;
    extern function int f();
  endclass
  function int c::f();
    int n;
    foreach (this.m_a[i]) n += m_a[i];
    foreach (m_s[j]) n += m_s[j];
    foreach (m_m[k]) n += m_m[k + 0];
    return n;
  endfunction
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
