// § cloneLoopVarLocalElemTs252
package p;
  typedef enum {RED, GREEN} color_e;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    color_e values[$];
    foreach (values[i]) begin
      color_e s;
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
