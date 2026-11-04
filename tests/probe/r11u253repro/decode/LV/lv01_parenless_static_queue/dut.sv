// § cloneLoopVarHomeObject183 (decode only, sister ground StmtEmit: the copy loop variable over a tf-item string local binds that local's string_typespec)
package p;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    static string values[$];
    foreach (values[i]) begin
      string s;
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
