// § aggCopyClassMemberHomeInst446
package p;
  class C;
  endclass
  class E;
  endclass
  typedef struct { C m; E e; int k; } s_t;
  typedef struct { s_t in; C c2; } o_t;
endpackage
package q;
  import p::*;
  class D;
    o_t x;
    s_t y;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
