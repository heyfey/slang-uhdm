// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    begin
      string values[$];
      foreach (values[i]) begin
        string s;
        s = values[i];
      end
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
