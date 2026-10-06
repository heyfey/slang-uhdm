// § cloneLoopVarClassScopedInt252
package p;
  class base; endclass
  class lib;
    protected int m_q[$];
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (this.m_q[i])
      s.push_back(i);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
