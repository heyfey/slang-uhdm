// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern function void m_set(int n);
  endclass
  function void comp::m_set(int n);
    if (n > 0) begin : blk
      logic [3:0] v[$];
      foreach (v[i]) n += int'(v[i]);
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
