// § cloneLoopVarClassScopedInt252
package p;
  class lib;
    typedef lib this_type;
    static int m_q[4][3];
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (this_type::m_q[i, j])
      s.push_back(i + j);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
