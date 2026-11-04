// § clsTdQueueLocalCloneUnsupported446
package p;
  class F;
    typedef struct { int a; string n; } al_t;
    extern static function int look(string s);
  endclass
  function int F::look(string s);
    al_t hits[$];
    al_t one[];
    foreach (hits[i]) one = new[i];
    return hits.size();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    function int g(); return F::look("a"); endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  D d;
endmodule
