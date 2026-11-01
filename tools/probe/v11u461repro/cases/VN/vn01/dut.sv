// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { enum logic [1:0] {A, B} e; bit [1:0] b; } u; bit [3:0] y; } s_t;
endpackage
module top;
  import p::*;
endmodule
