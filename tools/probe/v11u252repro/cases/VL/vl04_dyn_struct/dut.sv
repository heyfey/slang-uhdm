// § cloneLoopVarLocalElemTs252
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pkt_t;
  class comp;
    extern function void m_set;
  endclass
  function void comp::m_set;
    pkt_t d[];
    d = new[2];
    foreach (d[i]) begin
      logic [3:0] s;
      s = d[i].a;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
