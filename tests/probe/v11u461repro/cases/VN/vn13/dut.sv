// § pkgNestedAnonAggMemberInst461
package p;
  typedef union packed { union packed { logic [3:0] a; bit [3:0] b; } u; struct packed { bit [1:0] c; bit [1:0] d; } s; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
