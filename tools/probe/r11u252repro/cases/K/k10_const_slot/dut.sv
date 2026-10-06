// § cloneLoopVarClassScopedInt252
package p;
  class base; endclass
  class lib;
    typedef lib this_type;
    static logic [7:0] m_v[$];
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (this_type::m_v[i])
      s.push_back(this_type::m_v[i][3:0]);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
