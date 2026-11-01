// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { struct packed { union packed { bit [1:0] a; logic [1:0] b; } w; bit [1:0] c; } s; logic [3:0] d; } u; bit e; } s_t;
endpackage
module top;
  import p::*;
endmodule
