// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    extern function int m_get;
  endclass
  function int comp::m_get;
    int vals[$] = {1, 2, 3};
    int t;
    foreach (vals[i]) t += vals[i];
    return t;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
