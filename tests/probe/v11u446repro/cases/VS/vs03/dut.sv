// § aggCopyClassMemberHomeInst446
package r;
  class C;
  endclass
endpackage
package p;
  typedef struct { r::C m; string n; } s_t;
endpackage
package q;
  import p::*;
  class D;
    s_t x;
    function void f(s_t a); x = a; endfunction
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
