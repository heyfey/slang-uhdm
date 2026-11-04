// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    int values[4];
    foreach (values[i]) begin
      int s;
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
