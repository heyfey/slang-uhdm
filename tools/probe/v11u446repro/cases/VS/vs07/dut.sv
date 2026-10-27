// § aggCopyClassMemberHomeInst446
class C;
endclass
typedef struct { C m; int n; } us_t;
package p;
  class E;
  endclass
  typedef struct { E m; } s_t;
endpackage
module top;
  import p::*;
  us_t a;
  s_t b;
endmodule
