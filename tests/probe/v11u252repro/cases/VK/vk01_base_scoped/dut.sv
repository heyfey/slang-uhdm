// § cloneLoopVarClassScopedInt252
package p;
  class base; static int m_q[$]; endclass
  class lib extends base;
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (base::m_q[i])
      s.push_back(i);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
