// § aggCopyClassMemberHomeInst446
package p;
  class C;
  endclass
  typedef struct { C m; int k; } s_t;
  class H;
    s_t loc;
    function void f(s_t a);
      s_t b;
      b = a;
      loc = b;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  H h;
endmodule
