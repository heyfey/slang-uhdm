// § cloneLoopVarLocalElemTs252
package p;
  class item; int x; endclass
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    static item values[$];
    foreach (values[i]) begin
      int s;
      s = values[i].x;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
