// § cloneLoopVarClassScopedInt252
package p;
  class base; endclass
  class lib;
    typedef lib this_type;
    static int m_d[];
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (this_type::m_d[i])
      s.push_back(m_d[i]);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
