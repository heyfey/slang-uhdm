// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern task m_set;
  endclass
  task comp::m_set;
    string values[$];
    foreach (values[i]) begin
      string s;
      s = values[i];
    end
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
