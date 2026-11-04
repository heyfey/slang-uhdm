// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    string values[$];
    int k[$];
    foreach (values[i]) foreach (k[j]) begin
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
