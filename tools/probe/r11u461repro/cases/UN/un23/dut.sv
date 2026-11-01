// § pkgNestedAnonAggMemberInst461
package p;
  typedef union { struct { int a; bit [3:0] b; } s; int y; } u_t;
endpackage
module top;
  import p::*;
endmodule
