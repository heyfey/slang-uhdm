// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct { union { int a; int unsigned b; } u; int y; } s_t;
endpackage
module top;
  import p::*;
endmodule
