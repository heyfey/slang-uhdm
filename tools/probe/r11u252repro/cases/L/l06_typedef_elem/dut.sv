// § cloneLoopVarLocalElemTs252
package p;
  typedef int it_t;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    it_t values[$];
    foreach (values[i]) begin
      it_t s;
      s = values[i];
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
