// § aggCopyClassMemberHomeInst446
package p;
  class C;
  endclass
  typedef struct { C m; string n; } s_t;
endpackage
module top;
  import p::*;
  s_t v;
  initial v.n = "a";
endmodule
