// § cloneLoopVarClassScopedInt252
package p;
  class lib #(type T = int);
    static T m_q[$];
    int s[$];
    extern function void init();
  endclass
  function void lib::init();
    foreach (lib#(T)::m_q[i])
      s.push_back(i);
  endfunction
  class user;
    lib #(byte) l;
  endclass
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
