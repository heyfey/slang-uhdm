// § cloneLoopVarClassPropStringTs248
// control: a typedef'd string property keeps the placeholder
package p;
  typedef string str_t;
  class c;
    str_t m_t;
    extern function int f();
  endclass
  function int c::f();
    int n;
    foreach (m_t[i]) n += m_t[i];
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
