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
    al_t hits[];
    hits = new[1];
    return hits.size();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    F f;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
