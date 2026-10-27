// § clsTdQueueLocalCloneUnsupported446
package p;
  class F;
    typedef struct {
      int a;
      string n;
    } al_t;
    al_t m_al[$];
    extern function int look(string s);
  endclass
  function int F::look(string s);
    al_t hits[$];
    hits = m_al.find(i) with (i.n == s);
    return hits.size();
  endfunction
endpackage
module top;
  import p::*;
  F f;
endmodule
