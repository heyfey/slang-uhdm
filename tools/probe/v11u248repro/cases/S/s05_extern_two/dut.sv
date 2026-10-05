// § cloneLoopVarClassPropStringTs248
package p;
  class c;
    local string m_name;
    string m_q[$];
    extern function int f();
  endclass
  function int c::f();
    f = 0;
    foreach (m_name[i]) f++;
    foreach (m_q[i]) f++;
    foreach (m_q[i]) foreach (m_name[j]) f += i + j;
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
