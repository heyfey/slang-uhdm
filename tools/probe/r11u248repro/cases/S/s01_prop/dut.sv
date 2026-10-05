// § cloneLoopVarClassPropStringTs248
package p;
  class c;
    protected string m_name;
    extern function int unsigned get_depth();
  endclass
  function int unsigned c::get_depth();
    if (m_name == "") return 0;
    get_depth = 1;
    foreach (m_name[i])
      if (m_name[i] == ".") ++get_depth;
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
