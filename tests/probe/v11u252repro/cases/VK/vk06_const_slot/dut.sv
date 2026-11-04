// § cloneLoopVarClassScopedInt252
package p;
  class lib;
    typedef lib this_type;
    static bit [7:0] m_q[$];
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (this_type::m_q[i])
      s.push_back(this_type::m_q[i][3:0] + m_q[i][i +: 2]);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
