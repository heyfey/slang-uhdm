// § cloneLoopVarLocalElemTs252
package p;
  class item; endclass
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    item values[$];
    foreach (values[i]) begin
      item s;
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
