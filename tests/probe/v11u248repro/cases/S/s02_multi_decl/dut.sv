// § cloneLoopVarClassPropStringTs248
package p;
  class c;
    string m_name, m_alt;
    extern function int f();
  endclass
  function int c::f();
    f = 0;
    foreach (m_alt[j])
      f += m_alt[j];
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
