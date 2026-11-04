// § cloneLoopVarLocalElemTs252
package p;
  function automatic void m_set;
    string values[$];
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
