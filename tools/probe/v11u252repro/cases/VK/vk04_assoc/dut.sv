// § cloneLoopVarClassScopedInt252
package p;
  class lib;
    typedef lib this_type;
    static int m_a[string];
    string s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (this_type::m_a[k])
      s.push_back(k);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
