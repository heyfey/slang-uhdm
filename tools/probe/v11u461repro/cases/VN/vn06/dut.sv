// § pkgNestedAnonAggMemberInst461
package p;
  typedef logic [3:0] n_t;
  typedef struct packed { union packed { n_t a; bit [3:0] b; } u; bit [3:0] y; } s_t;
endpackage
module top;
  import p::*;
endmodule
