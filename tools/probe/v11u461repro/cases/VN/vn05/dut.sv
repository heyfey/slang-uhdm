// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { logic [3:0] a; bit [3:0] b; } u; bit [3:0] y; } s_t;
  class K;
    s_t m;
  endclass
endpackage
module top;
  import p::*;
endmodule
