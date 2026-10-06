// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    logic [7:0] values[$];
    foreach (values[i]) begin
      logic [3:0] s;
      s = values[i][3:0] + values[i][7 -: 4];
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
