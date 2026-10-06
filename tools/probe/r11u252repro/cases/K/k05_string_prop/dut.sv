// § cloneLoopVarClassScopedInt252
package p;
  class base; endclass
  class lib;
    typedef lib this_type;
    static string m_s;
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (this_type::m_s[i])
      s.push_back(i);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
