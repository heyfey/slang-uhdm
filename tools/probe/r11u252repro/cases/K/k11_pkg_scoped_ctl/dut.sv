// § cloneLoopVarClassScopedInt252
package p;
  int pq[$];
  class lib;
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (p::pq[i])
      s.push_back(p::pq[i]);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
