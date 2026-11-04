// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { logic [3:0] a; bit [3:0] b; } u; bit [7:0] y; } s_t;
endpackage
module top;
  import p::*;
endmodule
