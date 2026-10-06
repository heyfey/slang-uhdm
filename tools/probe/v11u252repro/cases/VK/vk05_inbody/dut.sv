// § cloneLoopVarClassScopedInt252
package p;
  class lib;
    typedef lib this_type;
    static int m_q[$];
    int s[$];
    function void init();
      foreach (this_type::m_q[i])
        s.push_back(m_q[i]);
    endfunction
  endclass
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
