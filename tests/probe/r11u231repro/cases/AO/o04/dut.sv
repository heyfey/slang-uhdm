// § tfArgImportCloneFollowsIn231 — a struct typedef on the out-of-body method
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  class c1;
    extern function void f(s_t x);
  endclass
  function void c1::f(s_t x);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
