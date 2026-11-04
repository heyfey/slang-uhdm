// § pkgNestedAnonAggMemberInst461
package p;
  typedef union packed { union packed { logic [3:0] a; bit [3:0] b; } w; bit [3:0] y; } u_t;
endpackage
module top;
  import p::*;
endmodule
