// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    static int values[$][$];
    foreach (values[i, j]) begin
      int s;
      s = values[i][j];
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
