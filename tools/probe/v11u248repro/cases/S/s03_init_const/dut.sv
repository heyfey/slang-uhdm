// § cloneLoopVarClassPropStringTs248
package p;
  class c;
    string m_name = "a.b";
    const string m_k = "xy";
    extern function int f();
  endclass
  function int c::f();
    f = 0;
    foreach (m_name[i]) f += (m_name[i] == ".");
    foreach (m_k[i]) f += m_k[i];
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
